from fastapi import Request

from backend.shared.database.base_document import UserRole
from backend.shared.database.documents import AuditLogDocument


class AuditService:
    async def record(
        self,
        action: str,
        resource: str,
        actor_user_id: str | None = None,
        actor_role: UserRole = UserRole.SYSTEM,
        resource_id: str | None = None,
        request: Request | None = None,
        before: dict | None = None,
        after: dict | None = None,
    ) -> AuditLogDocument:
        return await AuditLogDocument(
            actor_user_id=actor_user_id,
            actor_role=actor_role,
            action=action,
            resource=resource,
            resource_id=resource_id,
            ip_address=request.client.host if request and request.client else None,
            user_agent=request.headers.get("user-agent") if request else None,
            before=before,
            after=after,
        ).insert()


audit_service = AuditService()
