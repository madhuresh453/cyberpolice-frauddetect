"""Bank Account Freeze Service"""
import uuid
from datetime import UTC, datetime

from fastapi import HTTPException, Request, status

from backend.shared.database.bank_documents import (
    BankAccountDocument,
    FreezeRequestDocument,
    FreezeStatus,
    SuspiciousTransactionDocument,
)
from backend.shared.database.documents import AuditLogDocument
from ..schemas.bank_schemas import FreezeAccountRequest, FreezeAccountResponse


class FreezeService:
    async def freeze_account(
        self,
        payload: FreezeAccountRequest,
        user_id: str,
        request: Request,
    ) -> FreezeAccountResponse:
        """Create a freeze request for a bank account."""
        # Check if account exists
        account = await BankAccountDocument.find_one(
            {"account_number": payload.account_number, "ifsc_code": payload.ifsc_code}
        )
        if not account:
            # Create account record if it doesn't exist
            account = await BankAccountDocument(
                account_number=payload.account_number,
                ifsc_code=payload.ifsc_code,
                bank_name=payload.bank_name,
                account_holder_name="Pending Verification",
                status="active",
            ).insert()

        if account.balance_frozen:
            raise HTTPException(status_code=409, detail="Account is already frozen")

        # Create freeze request
        request_id = f"FRZ-{uuid.uuid4().hex[:12].upper()}"
        freeze_request = await FreezeRequestDocument(
            request_id=request_id,
            account_number=payload.account_number,
            ifsc_code=payload.ifsc_code,
            bank_name=payload.bank_name,
            requested_by=user_id,
            requested_by_role="police",
            reason=payload.reason,
            freeze_type=payload.freeze_type,
            amount_to_freeze=payload.amount_to_freeze,
            linked_case_id=payload.linked_case_id,
            evidence_ids=payload.evidence_ids,
            status=FreezeStatus.PENDING,
        ).insert()

        # Update account status
        account.balance_frozen = True
        account.frozen_at = datetime.now(UTC)
        account.frozen_by = user_id
        account.freeze_reason = payload.reason
        await account.save()

        # Audit log
        await AuditLogDocument(
            actor_user_id=user_id,
            actor_role="police",
            action="FREEZE_ACCOUNT",
            resource="bank_accounts",
            resource_id=request_id,
            after={
                "account_number": payload.account_number,
                "ifsc_code": payload.ifsc_code,
                "freeze_type": payload.freeze_type,
                "reason": payload.reason,
            },
            ip_address=request.client.host if request.client else None,
        ).insert()

        return FreezeAccountResponse(
            request_id=request_id,
            account_number=payload.account_number,
            ifsc_code=payload.ifsc_code,
            bank_name=payload.bank_name,
            freeze_type=payload.freeze_type,
            status="pending",
            created_at=datetime.now(UTC).isoformat(),
            message=f"Freeze request {request_id} submitted to {payload.bank_name}",
        )

    async def approve_freeze(
        self,
        request_id: str,
        approver_id: str,
        request: Request,
    ) -> dict:
        """Approve a freeze request."""
        freeze = await FreezeRequestDocument.find_one(
            FreezeRequestDocument.request_id == request_id
        )
        if not freeze:
            raise HTTPException(status_code=404, detail="Freeze request not found")
        if freeze.status != FreezeStatus.PENDING:
            raise HTTPException(status_code=409, detail="Request already processed")

        freeze.status = FreezeStatus.APPROVED
        freeze.approved_by = approver_id
        freeze.approved_at = datetime.now(UTC)
        await freeze.save()

        await AuditLogDocument(
            actor_user_id=approver_id,
            action="APPROVE_FREEZE",
            resource="freeze_requests",
            resource_id=request_id,
            before={"status": "pending"},
            after={"status": "approved"},
            ip_address=request.client.host if request.client else None,
        ).insert()

        return {"status": "approved", "request_id": request_id}

    async def reject_freeze(
        self,
        request_id: str,
        approver_id: str,
        reason: str,
        request: Request,
    ):
        """Reject a freeze request."""
        freeze = await FreezeRequestDocument.find_one(
            FreezeRequestDocument.request_id == request_id
        )
        if not freeze:
            raise HTTPException(status_code=404, detail="Freeze request not found")

        freeze.status = FreezeStatus.REJECTED
        freeze.rejection_reason = reason
        freeze.approved_by = approver_id
        freeze.approved_at = datetime.now(UTC)
        await freeze.save()

        # Unfreeze the account
        account = await BankAccountDocument.find_one(
            {"account_number": freeze.account_number, "ifsc_code": freeze.ifsc_code}
        )
        if account:
            account.balance_frozen = False
            account.frozen_at = None
            account.frozen_by = None
            await account.save()

        return {"status": "rejected", "request_id": request_id, "reason": reason}

    async def unfreeze_account(
        self,
        account_number: str,
        ifsc_code: str,
        user_id: str,
        request: Request,
    ):
        """Release a frozen account."""
        account = await BankAccountDocument.find_one(
            {"account_number": account_number, "ifsc_code": ifsc_code}
        )
        if not account:
            raise HTTPException(status_code=404, detail="Account not found")

        account.balance_frozen = False
        account.frozen_at = None
        account.frozen_by = None
        account.freeze_reason = None
        await account.save()

        # Update active freeze requests
        pending_freeze = await FreezeRequestDocument.find(
            FreezeRequestDocument.account_number == account_number,
            FreezeRequestDocument.status == FreezeStatus.APPROVED,
        ).to_list()

        for fr in pending_freeze:
            fr.status = FreezeStatus.RELEASED
            fr.released_by = user_id
            fr.released_at = datetime.now(UTC)
            await fr.save()

        return {"status": "unfrozen", "account_number": account_number}


freeze_service = FreezeService()