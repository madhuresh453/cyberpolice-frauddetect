from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from backend.shared.database.documents import SessionDocument, UserDocument
from services.token_service import token_service

bearer = HTTPBearer(auto_error=False)


async def get_current_user(
    request: Request, credentials: HTTPAuthorizationCredentials | None = Depends(bearer)
) -> UserDocument:
    if credentials is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Bearer token required")
    try:
        payload = token_service.verify_token(credentials.credentials)
    except Exception as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token") from exc
    session = await SessionDocument.get(payload["sid"])
    if not session or session.status != "active":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Session is inactive")
    user = await UserDocument.get(payload["sub"])
    if not user or user.status != "active":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User is inactive")
    request.state.user = user
    request.state.session = session
    return user
