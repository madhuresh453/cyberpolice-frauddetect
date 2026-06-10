"""Bank Account Routes"""
from fastapi import APIRouter, Depends, HTTPException, Request, status

from backend.shared.database.bank_documents import BankAccountDocument, FraudComplaintDocument, SuspiciousTransactionDocument
from backend.services.auth_service.middleware.jwt_middleware import get_current_user
from backend.services.auth_service.middleware.rbac_middleware import require_permissions
from backend.shared.database.documents import UserDocument
from ..schemas.bank_schemas import (
    AccountLookupRequest, AccountLookupResponse,
    FreezeAccountRequest, FreezeAccountResponse,
    ComplaintCreateRequest, ComplaintResponse,
    TransactionQueryResponse,
)

router = APIRouter(prefix="/accounts", tags=["Bank Accounts"])


@router.post("/lookup", response_model=AccountLookupResponse)
async def lookup_account(
    request: Request,
    payload: AccountLookupRequest,
    user: UserDocument = Depends(require_permissions("VIEW_BANK_ACCOUNTS")),
):
    """Look up a bank account by account number + IFSC or phone number."""
    query = {}
    if payload.account_number and payload.ifsc_code:
        query = {"account_number": payload.account_number, "ifsc_code": payload.ifsc_code}
    elif payload.phone_number:
        query = {"phone_number": payload.phone_number}
    else:
        raise HTTPException(status_code=400, detail="Provide account_number+ifsc_code or phone_number")

    account = await BankAccountDocument.find_one(query)
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")

    return AccountLookupResponse(
        account_number=account.account_number,
        ifsc_code=account.ifsc_code,
        bank_name=account.bank_name,
        account_holder_name=account.account_holder_name,
        status=account.status,
        risk_score=account.risk_score,
        balance_frozen=account.balance_frozen,
        complaints_count=account.complaints_count,
        upi_ids=account.upi_ids,
    )


@router.post("/freeze", response_model=FreezeAccountResponse)
async def freeze_account(
    request: Request,
    payload: FreezeAccountRequest,
    user: UserDocument = Depends(require_permissions("MANAGE_FREEZE")),
):
    """Freeze a bank account."""
    from ..services.freeze_service import freeze_service
    result = await freeze_service.freeze_account(payload, str(user.id), request)
    return result


@router.post("/unfreeze/{account_number}/{ifsc_code}")
async def unfreeze_account(
    account_number: str,
    ifsc_code: str,
    request: Request,
    user: UserDocument = Depends(require_permissions("MANAGE_FREEZE")),
):
    """Unfreeze a bank account."""
    from ..services.freeze_service import freeze_service
    await freeze_service.unfreeze_account(account_number, ifsc_code, str(user.id), request)
    return {"status": "unfrozen"}


@router.get("/{account_number}/transactions")
async def get_transactions(
    account_number: str,
    ifsc_code: str,
    limit: int = 50,
    skip: int = 0,
    user: UserDocument = Depends(require_permissions("VIEW_BANK_ACCOUNTS")),
):
    """Get suspicious transactions for an account."""
    transactions = await SuspiciousTransactionDocument.find(
        SuspiciousTransactionDocument.account_number == account_number
    ).sort(-SuspiciousTransactionDocument.timestamp).skip(skip).limit(limit).to_list()

    return {
        "account_number": account_number,
        "total": len(transactions),
        "transactions": [
            {
                "transaction_id": t.transaction_id,
                "amount": t.amount,
                "transaction_type": t.transaction_type,
                "counterparty_account": t.counterparty_account,
                "counterparty_upi": t.counterparty_upi,
                "timestamp": t.timestamp.isoformat(),
                "risk_score": t.risk_score,
                "risk_factors": t.risk_factors,
                "status": t.status,
            }
            for t in transactions
        ],
    }


@router.post("/complaints", status_code=201)
async def create_complaint(
    request: Request,
    payload: ComplaintCreateRequest,
    user: UserDocument = Depends(get_current_user),
):
    """Submit a fraud complaint."""
    from ..services.complaint_service import complaint_service
    result = await complaint_service.create_complaint(payload, str(user.id), request)
    return result


@router.get("/complaints/{complaint_id}")
async def get_complaint(
    complaint_id: str,
    user: UserDocument = Depends(require_permissions("VIEW_COMPLAINTS")),
):
    """Get fraud complaint details."""
    complaint = await FraudComplaintDocument.find_one(
        FraudComplaintDocument.complaint_id == complaint_id
    )
    if not complaint:
        raise HTTPException(status_code=404, detail="Complaint not found")
    return {
        "complaint_id": complaint.complaint_id,
        "complaint_type": complaint.complaint_type,
        "account_number": complaint.account_number,
        "upi_id": complaint.upi_id,
        "amount_involved": complaint.amount_involved,
        "description": complaint.description,
        "status": complaint.status,
        "created_at": complaint.created_at.isoformat(),
        "linked_case_id": complaint.linked_case_id,
        "freeze_request_id": complaint.freeze_request_id,
    }