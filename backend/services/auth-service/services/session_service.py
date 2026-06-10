import hashlib
from datetime import UTC, datetime, timedelta

from fastapi import Request

from backend.shared.database.database import get_settings
from backend.shared.database.documents import SessionDocument, UserDocument


class SessionService:
    @staticmethod
    def fingerprint_from_request(request: Request, supplied: str | None = None) -> str:
        if supplied:
            return supplied
        raw = "|".join(
            [
                request.headers.get("user-agent", ""),
                request.headers.get("accept-language", ""),
                request.headers.get("x-device-id", ""),
                request.client.host if request.client else "",
            ]
        )
        return hashlib.sha256(raw.encode("utf-8")).hexdigest()

    async def create_session(
        self, user: UserDocument, refresh_token_hash: str, request: Request, device_fingerprint: str
    ) -> SessionDocument:
        settings = get_settings()
        return await SessionDocument(
            user_id=str(user.id),
            refresh_token_hash=refresh_token_hash,
            device_fingerprint=device_fingerprint,
            device_type=request.headers.get("x-device-type", "browser"),
            ip_address=request.client.host if request.client else "unknown",
            user_agent=request.headers.get("user-agent", "unknown"),
            location={"source": "ip", "value": request.headers.get("x-forwarded-for", "")},
            expires_at=datetime.now(UTC) + timedelta(days=settings.refresh_token_days),
            access_roles=[user.user_type],
        ).insert()

    async def active_sessions(self, user_id: str) -> list[SessionDocument]:
        return await SessionDocument.find(
            SessionDocument.user_id == user_id, SessionDocument.status == "active"
        ).sort(-SessionDocument.created_at).to_list()

    async def revoke_session(self, user_id: str, session_id: str) -> bool:
        session = await SessionDocument.get(session_id)
        if not session or session.user_id != user_id:
            return False
        session.status = "revoked"
        session.revoked_at = datetime.now(UTC)
        await session.save()
        return True

    async def revoke_all(self, user_id: str) -> int:
        sessions = await self.active_sessions(user_id)
        for session in sessions:
            session.status = "revoked"
            session.revoked_at = datetime.now(UTC)
            await session.save()
        return len(sessions)


session_service = SessionService()
