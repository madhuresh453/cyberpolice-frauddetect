from fastapi import APIRouter, Depends

from backend.shared.database.documents import PermissionDocument, RoleDocument
from middleware.rbac_middleware import require_permissions
from schemas.role import PermissionCreate, RoleCreate

router = APIRouter(prefix="/roles", tags=["roles"])


@router.post("", status_code=201)
async def create_role(payload: RoleCreate, _user=Depends(require_permissions("SYSTEM_ADMIN"))):
    role = await RoleDocument(
        name=payload.name,
        description=payload.description,
        role_type=payload.role_type,
        permissions=payload.permissions,
    ).insert()
    return {"id": str(role.id), "name": role.name}


@router.get("")
async def list_roles(_user=Depends(require_permissions("MANAGE_USERS"))):
    roles = await RoleDocument.find(RoleDocument.deleted_at == None).to_list()  # noqa: E711
    return [{"id": str(role.id), "name": role.name, "permissions": role.permissions} for role in roles]


@router.post("/permissions", status_code=201)
async def create_permission(payload: PermissionCreate, _user=Depends(require_permissions("SYSTEM_ADMIN"))):
    permission = await PermissionDocument(
        code=payload.code,
        name=payload.name,
        description=payload.description,
    ).insert()
    return {"id": str(permission.id), "code": permission.code}
