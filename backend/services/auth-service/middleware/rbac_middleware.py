from collections.abc import Callable

from fastapi import Depends, HTTPException, status

from backend.shared.database.documents import UserDocument
from .jwt_middleware import get_current_user


def require_permissions(*required_permissions: str) -> Callable:
    async def dependency(user: UserDocument = Depends(get_current_user)) -> UserDocument:
        if "SYSTEM_ADMIN" in user.permissions:
            return user
        missing = [permission for permission in required_permissions if permission not in user.permissions]
        if missing:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail={"message": "Insufficient permissions", "missing": missing},
            )
        return user

    return dependency


def require_roles(*required_roles: str) -> Callable:
    async def dependency(user: UserDocument = Depends(get_current_user)) -> UserDocument:
        if user.user_type.value not in required_roles and not set(user.roles).intersection(required_roles):
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient role")
        return user

    return dependency
