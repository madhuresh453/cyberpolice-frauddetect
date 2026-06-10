from datetime import UTC, datetime, timedelta

from fastapi import HTTPException, Request, status
from passlib.context import CryptContext

from backend.shared.database.documents import RoleDocument, UserDocument
from schemas.auth import LoginRequest, RegisterRequest
from .audit_service import audit_service
from .mfa_service import mfa_service
from .session_service import session_service
from .token_service import token_service

pwd_context = CryptContext(schemes=["argon2"], deprecated="auto")


class AuthService:
    def hash_password(self, password: str) -> str:
        return pwd_context.hash(password)

    def verify_password(self, password: str, password_hash: str) -> bool:
        return pwd_context.verify(password, password_hash)

    async def register(self, payload: RegisterRequest, request: Request) -> UserDocument:
        existing = await UserDocument.find_one(
            {"$or": [{"email": payload.email}, {"phone_number": payload.phone_number}]}
        )
        if existing:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="User already exists")
        role = await RoleDocument.find_one(RoleDocument.role_type == payload.user_type)
        permissions = role.permissions if role else []
        user = await UserDocument(
            email=payload.email,
            phone_number=payload.phone_number,
            password_hash=self.hash_password(payload.password),
            full_name=payload.full_name,
            user_type=payload.user_type,
            roles=[payload.user_type.value],
            permissions=permissions,
            access_roles=[payload.user_type, "admin", "super_admin"],
        ).insert()
        await audit_service.record("REGISTER", "users", str(user.id), payload.user_type, str(user.id), request)
        return user

    async def authenticate(self, payload: LoginRequest, request: Request) -> tuple[UserDocument, str, str]:
        user = await UserDocument.find_one(UserDocument.email == payload.email)
        if not user:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
        if user.locked_until and user.locked_until > datetime.now(UTC):
            raise HTTPException(status_code=status.HTTP_423_LOCKED, detail="Account is temporarily locked")
        if not self.verify_password(payload.password, user.password_hash):
            user.failed_login_attempts += 1
            if user.failed_login_attempts >= 5:
                user.locked_until = datetime.now(UTC) + timedelta(minutes=15)
            await user.save()
            await audit_service.record("LOGIN_FAILED", "users", str(user.id), user.user_type, str(user.id), request)
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
        if user.mfa_enabled:
            valid_totp = payload.mfa_code and user.mfa_secret_encrypted and mfa_service.verify(
                user.mfa_secret_encrypted, payload.mfa_code
            )
            recovery_hash = mfa_service.hash_recovery_code(payload.recovery_code or "")
            valid_recovery = recovery_hash in user.recovery_code_hashes
            if not valid_totp and not valid_recovery:
                raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="MFA verification required")
            if valid_recovery:
                user.recovery_code_hashes.remove(recovery_hash)
        user.failed_login_attempts = 0
        user.locked_until = None
        user.last_login_at = datetime.now(UTC)
        await user.save()
        refresh_token = token_service.create_refresh_token()
        device_fingerprint = session_service.fingerprint_from_request(request, payload.device_fingerprint)
        session = await session_service.create_session(
            user, token_service.hash_token(refresh_token), request, device_fingerprint
        )
        access_token = token_service.create_access_token(user, str(session.id))
        await audit_service.record("LOGIN", "sessions", str(user.id), user.user_type, str(session.id), request)
        return user, access_token, refresh_token

    async def change_password(self, user: UserDocument, current_password: str, new_password: str, request: Request) -> None:
        if not self.verify_password(current_password, user.password_hash):
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid current password")
        user.password_hash = self.hash_password(new_password)
        await user.save()
        await session_service.revoke_all(str(user.id))
        await audit_service.record("PASSWORD_CHANGE", "users", str(user.id), user.user_type, str(user.id), request)


auth_service = AuthService()
