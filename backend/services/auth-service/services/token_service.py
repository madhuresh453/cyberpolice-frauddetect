import hashlib
import secrets
from datetime import UTC, datetime, timedelta
from typing import Any

import jwt

from backend.shared.database.database import get_settings
from backend.shared.database.documents import SessionDocument, UserDocument


class TokenService:
    def __init__(self) -> None:
        self.settings = get_settings()

    @staticmethod
    def hash_token(token: str) -> str:
        return hashlib.sha256(token.encode("utf-8")).hexdigest()

    def create_access_token(self, user: UserDocument, session_id: str) -> str:
        now = datetime.now(UTC)
        payload = {
            "sub": str(user.id),
            "email": user.email,
            "role": user.user_type,
            "roles": user.roles,
            "permissions": user.permissions,
            "sid": session_id,
            "type": "access",
            "iat": int(now.timestamp()),
            "exp": int((now + timedelta(minutes=self.settings.access_token_minutes)).timestamp()),
        }
        return jwt.encode(payload, self.settings.jwt_secret, algorithm=self.settings.jwt_algorithm)

    def create_refresh_token(self) -> str:
        return secrets.token_urlsafe(64)

    def verify_token(self, token: str, expected_type: str = "access") -> dict[str, Any]:
        payload = jwt.decode(token, self.settings.jwt_secret, algorithms=[self.settings.jwt_algorithm])
        if payload.get("type") != expected_type:
            raise jwt.InvalidTokenError("Invalid token type")
        return payload

    async def revoke_token(self, refresh_token: str) -> None:
        token_hash = self.hash_token(refresh_token)
        session = await SessionDocument.find_one(SessionDocument.refresh_token_hash == token_hash)
        if session:
            session.status = "revoked"
            session.revoked_at = datetime.now(UTC)
            await session.save()

    async def rotate_refresh_token(
        self, refresh_token: str, device_fingerprint: str | None = None
    ) -> tuple[UserDocument, SessionDocument, str]:
        token_hash = self.hash_token(refresh_token)
        session = await SessionDocument.find_one(SessionDocument.refresh_token_hash == token_hash)
        if not session or session.status != "active" or session.expires_at <= datetime.now(UTC):
            raise ValueError("Refresh token is invalid or expired")
        if device_fingerprint and session.device_fingerprint != device_fingerprint:
            raise ValueError("Device fingerprint mismatch")
        user = await UserDocument.get(session.user_id)
        if not user or user.status != "active":
            raise ValueError("User is not active")
        new_refresh_token = self.create_refresh_token()
        session.refresh_token_hash = self.hash_token(new_refresh_token)
        session.last_seen_at = datetime.now(UTC)
        await session.save()
        return user, session, new_refresh_token


token_service = TokenService()
