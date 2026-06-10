from pydantic import BaseModel, Field

from backend.shared.database.base_document import UserRole


class RoleCreate(BaseModel):
    name: str = Field(min_length=2, max_length=80)
    role_type: UserRole
    description: str = ""
    permissions: list[str] = Field(default_factory=list)


class PermissionCreate(BaseModel):
    code: str = Field(min_length=2, max_length=80)
    name: str = Field(min_length=2, max_length=120)
    description: str = ""
