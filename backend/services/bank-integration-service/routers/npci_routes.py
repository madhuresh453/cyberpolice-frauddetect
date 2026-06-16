"""NPCI Integration Routes"""
from fastapi import APIRouter, Depends, Request

from backend.shared.database.documents import UserDocument
from backend.services.auth_service.middleware.rbac_middleware import require_permissions
from ..schemas.bank_schemas import NPCIRegisterRequest, NPCIRegisterResponse

router = APIRouter(prefix="/npci", tags=["NPCI Integration"])


@router.post("/register", response_model=NPCIRegisterResponse)
async def register_npci(
    payload: NPCIRegisterRequest,
    user: UserDocument = Depends(require_permissions("MANAGE_BANK_INTEGRATION")),
):
    """Register a bank with NPCI."""
    from ..services.npci_service import npci_service
    return await npci_service.register(payload, user)


@router.post("/fraud-report")
async def submit_fraud_report(
    request: Request,
    user: UserDocument = Depends(require_permissions("MANAGE_BANK_INTEGRATION")),
):
    """Submit fraud report to NPCI."""
    from ..services.npci_service import npci_service
    body = await request.json()
    return await npci_service.submit_fraud_report(body, user)