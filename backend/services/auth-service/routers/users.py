from fastapi import APIRouter, Depends

from backend.shared.database.documents import UserDocument
from middleware.rbac_middleware import require_permissions
from schemas.user import UserRead, UserUpdate
from routers.auth import user_to_read

router = APIRouter(prefix="/users", tags=["users"])


@router.get("", response_model=list[UserRead])
async def list_users(_user=Depends(require_permissions("MANAGE_USERS"))):
    users = await UserDocument.find(UserDocument.deleted_at == None).limit(100).to_list()  # noqa: E711
    return [user_to_read(user) for user in users]


@router.patch("/{user_id}", response_model=UserRead)
async def update_user(user_id: str, payload: UserUpdate, _user=Depends(require_permissions("MANAGE_USERS"))):
    user = await UserDocument.get(user_id)
    if payload.full_name is not None:
        user.full_name = payload.full_name
    if payload.status is not None:
        user.status = payload.status
    if payload.roles is not None:
        user.roles = payload.roles
    if payload.permissions is not None:
        user.permissions = payload.permissions
    await user.save()
    return user_to_read(user)
