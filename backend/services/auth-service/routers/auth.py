from fastapi import APIRouter, Depends, Request

from backend.shared.database.documents import UserDocument
from middleware.jwt_middleware import get_current_user
from schemas.auth import (
    ChangePasswordRequest,
    ForgotPasswordRequest,
    LoginRequest,
    MFASetupResponse,
    MFAVerifyRequest,
    RefreshRequest,
    RegisterRequest,
    ResetPasswordRequest,
    TokenResponse,
)
from schemas.user import UserRead
from services.audit_service import audit_service
from services.auth_service import auth_service
from services.mfa_service import mfa_service
from services.token_service import token_service

router = APIRouter(prefix="/auth", tags=["auth"])


def user_to_read(user: UserDocument) -> UserRead:
    return UserRead(
        id=str(user.id),
        email=user.email,
        phone_number=user.phone_number,
        full_name=user.full_name,
        user_type=user.user_type.value,
        roles=user.roles,
        permissions=user.permissions,
        status=user.status,
        mfa_enabled=user.mfa_enabled,
        last_login_at=user.last_login_at,
    )


@router.post("/register", response_model=UserRead, status_code=201)
async def register(payload: RegisterRequest, request: Request):
    return user_to_read(await auth_service.register(payload, request))


@router.post("/login", response_model=TokenResponse)
async def login(payload: LoginRequest, request: Request):
    _user, access_token, refresh_token = await auth_service.authenticate(payload, request)
    return TokenResponse(access_token=access_token, refresh_token=refresh_token)


@router.post("/logout")
async def logout(payload: RefreshRequest, request: Request, user: UserDocument = Depends(get_current_user)):
    await token_service.revoke_token(payload.refresh_token)
    await audit_service.record("LOGOUT", "sessions", str(user.id), user.user_type, None, request)
    return {"status": "logged_out"}


@router.post("/refresh", response_model=TokenResponse)
async def refresh(payload: RefreshRequest):
    user, session, refresh_token = await token_service.rotate_refresh_token(
        payload.refresh_token, payload.device_fingerprint
    )
    return TokenResponse(
        access_token=token_service.create_access_token(user, str(session.id)),
        refresh_token=refresh_token,
    )


@router.post("/change-password")
async def change_password(
    payload: ChangePasswordRequest, request: Request, user: UserDocument = Depends(get_current_user)
):
    await auth_service.change_password(user, payload.current_password, payload.new_password, request)
    return {"status": "password_changed"}


@router.post("/forgot-password")
async def forgot_password(payload: ForgotPasswordRequest, request: Request):
    await audit_service.record("PASSWORD_RESET_REQUEST", "users", None, resource_id=payload.email, request=request)
    return {"status": "reset_instructions_queued"}


@router.post("/reset-password")
async def reset_password(payload: ResetPasswordRequest, request: Request):
    await audit_service.record("PASSWORD_RESET_ATTEMPT", "users", None, resource_id=payload.reset_token[:12], request=request)
    return {"status": "reset_token_received"}


@router.post("/mfa/setup", response_model=MFASetupResponse)
async def mfa_setup(user: UserDocument = Depends(get_current_user)):
    secret = mfa_service.generate_secret()
    recovery_codes = mfa_service.generate_recovery_codes()
    user.mfa_secret_encrypted = secret
    user.recovery_code_hashes = [mfa_service.hash_recovery_code(code) for code in recovery_codes]
    await user.save()
    uri = mfa_service.provisioning_uri(user.email, secret)
    return MFASetupResponse(
        secret=secret,
        provisioning_uri=uri,
        qr_code_svg=mfa_service.qr_svg(uri),
        recovery_codes=recovery_codes,
    )


@router.post("/mfa/verify")
async def mfa_verify(payload: MFAVerifyRequest, request: Request, user: UserDocument = Depends(get_current_user)):
    valid_code = payload.code and user.mfa_secret_encrypted and mfa_service.verify(user.mfa_secret_encrypted, payload.code)
    valid_recovery = payload.recovery_code and mfa_service.hash_recovery_code(payload.recovery_code) in user.recovery_code_hashes
    if not valid_code and not valid_recovery:
        return {"verified": False}
    user.mfa_enabled = True
    await user.save()
    await audit_service.record("MFA_ENABLED", "users", str(user.id), user.user_type, str(user.id), request)
    return {"verified": True}


@router.get("/me", response_model=UserRead)
async def me(user: UserDocument = Depends(get_current_user)):
    return user_to_read(user)
