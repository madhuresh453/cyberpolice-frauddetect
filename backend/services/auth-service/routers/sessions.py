from fastapi import APIRouter, Depends

from backend.shared.database.documents import UserDocument
from middleware.jwt_middleware import get_current_user
from schemas.session import SessionRead
from services.session_service import session_service

router = APIRouter(prefix="/sessions", tags=["sessions"])


def session_to_read(session) -> SessionRead:
    return SessionRead(
        id=str(session.id),
        device_fingerprint=session.device_fingerprint,
        device_type=session.device_type,
        ip_address=session.ip_address,
        user_agent=session.user_agent,
        location=session.location,
        status=session.status,
        created_at=session.created_at,
        last_seen_at=session.last_seen_at,
        expires_at=session.expires_at,
    )


@router.get("", response_model=list[SessionRead])
async def active_sessions(user: UserDocument = Depends(get_current_user)):
    return [session_to_read(session) for session in await session_service.active_sessions(str(user.id))]


@router.delete("/{session_id}")
async def revoke_session(session_id: str, user: UserDocument = Depends(get_current_user)):
    revoked = await session_service.revoke_session(str(user.id), session_id)
    return {"revoked": revoked}


@router.delete("")
async def revoke_all_sessions(user: UserDocument = Depends(get_current_user)):
    count = await session_service.revoke_all(str(user.id))
    return {"revoked": count}
