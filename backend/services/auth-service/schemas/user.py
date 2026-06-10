from datetime import datetime

from pydantic import BaseModel, EmailStr


class UserRead(BaseModel):
    id: str
    email: EmailStr
    phone_number: str
    full_name: str
    user_type: str
    roles: list[str]
    permissions: list[str]
    status: str
    mfa_enabled: bool
    last_login_at: datetime | None = None


class UserUpdate(BaseModel):
    full_name: str | None = None
    status: str | None = None
    roles: list[str] | None = None
    permissions: list[str] | None = None
