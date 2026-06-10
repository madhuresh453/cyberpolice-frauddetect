from pydantic import BaseModel, EmailStr, Field

from backend.shared.database.base_document import UserRole


class RegisterRequest(BaseModel):
    email: EmailStr
    phone_number: str
    password: str = Field(min_length=12, max_length=128)
    full_name: str = Field(min_length=2, max_length=160)
    user_type: UserRole = UserRole.CITIZEN


class LoginRequest(BaseModel):
    email: EmailStr
    password: str
    mfa_code: str | None = None
    recovery_code: str | None = None
    device_fingerprint: str | None = None


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int = 900


class RefreshRequest(BaseModel):
    refresh_token: str
    device_fingerprint: str | None = None


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str = Field(min_length=12, max_length=128)


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    reset_token: str
    new_password: str = Field(min_length=12, max_length=128)


class MFASetupResponse(BaseModel):
    secret: str
    provisioning_uri: str
    qr_code_svg: str
    recovery_codes: list[str]


class MFAVerifyRequest(BaseModel):
    code: str | None = None
    recovery_code: str | None = None
