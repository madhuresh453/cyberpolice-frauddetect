"""Freeze Request Routes"""
from fastapi import APIRouter, Depends, Request

from backend.shared.database.documents import UserDocument
from backend.services.auth_service.middleware.rbac_middleware import require_permissions
from ..schemas.bank_schemas import FreezeAccountRequest, FreezeAccountResponse
from ..services.freeze_service import freeze_service

router = APIRouter(prefix="/freeze", tags=["Account Freeze"])


@router.post("/emergency-hold")
async def emergency_hold(
    request: Request,
    payload: FreezeAccountRequest,
    user: UserDocument = Depends(require_permissions("MANAGE_FREEZE")),
):
    """Place an emergency hold on an account."""
    return await freeze_service.freeze_account(payload, str(user.id), request)


@router.post("/approve/{request_id}")
async def approve_freeze(
    request_id: str,
    request: Request,
    user: UserDocument = Depends(require_permissions("MANAGE_FREEZE")),
):
    """Approve a freeze request."""
    return await freeze_service.approve_freeze(request_id, str(user.id), request)


@router.post("/reject/{request_id}")
async def reject_freeze(
    request_id: str,
    request: Request,
    reason: str = "",
    user: UserDocument = Depends(require_permissions("MANAGE_FREEZE")),
):
    """Reject a freeze request."""
    return await freeze_service.reject_freeze(request_id, str(user.id), reason, request)