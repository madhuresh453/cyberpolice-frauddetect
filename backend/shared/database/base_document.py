from datetime import UTC, datetime
from enum import StrEnum
from typing import Any

from beanie import Document
from pydantic import Field


class UserRole(StrEnum):
    CITIZEN = "citizen"
    POLICE = "police"
    ISP = "isp"
    ADMIN = "admin"
    SUPER_ADMIN = "super_admin"
    SYSTEM = "system"


class RiskLevel(StrEnum):
    SAFE = "safe"
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class BaseDocument(Document):
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
    deleted_at: datetime | None = None
    created_by: str | None = None
    created_by_role: UserRole = UserRole.SYSTEM
    access_roles: list[UserRole] = Field(default_factory=lambda: [UserRole.ADMIN, UserRole.SUPER_ADMIN])
    metadata: dict[str, Any] = Field(default_factory=dict)

    async def soft_delete(self, deleted_by: str | None = None) -> None:
        self.deleted_at = datetime.now(UTC)
        self.metadata["deleted_by"] = deleted_by
        await self.save()

    class Settings:
        use_state_management = True
