"""UPI Verification Routes"""
from fastapi import APIRouter, Depends

from backend.shared.database.documents import UserDocument
from backend.services.auth_service.middleware.rbac_middleware import require_permissions
from ..schemas.bank_schemas import UPIVerifyRequest, UPIVerifyResponse

router = APIRouter(prefix="/upi", tags=["UPI Verification"])


@router.post("/verify", response_model=UPIVerifyResponse)
async def verify_upi(
    payload: UPIVerifyRequest,
    user: UserDocument = Depends(require_permissions("VIEW_BANK_ACCOUNTS")),
):
    """Verify a UPI ID."""
    from ..services.upi_service import upi_service
    return await upi_service.verify_upi(payload, user)


@router.get("/{upi_id}/risk")
async def get_upi_risk(
    upi_id: str,
    user: UserDocument = Depends(require_permissions("VIEW_BANK_ACCOUNTS")),
):
    """Get risk score for a UPI ID."""
    from ..services.upi_service import upi_service
    return await upi_service.get_upi_risk(upi_id)