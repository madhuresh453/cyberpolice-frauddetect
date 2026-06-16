"""Fraud Complaint Service"""
import uuid
from datetime import UTC, datetime

from fastapi import HTTPException

from backend.shared.database.bank_documents import FraudComplaintDocument, ComplaintStatus
from backend.shared.database.documents import AuditLogDocument
from ..schemas.bank_schemas import ComplaintCreateRequest, ComplaintResponse


class ComplaintService:
    async def create_complaint(
        self,
        payload: ComplaintCreateRequest,
        user_id: str,
        request,
    ) -> ComplaintResponse:
        complaint_id = f"CMP-{uuid.uuid4().hex[:12].upper()}"
        complaint = await FraudComplaintDocument(
            complaint_id=complaint_id,
            citizen_id=user_id,
            complaint_type=payload.complaint_type,
            account_number=payload.account_number,
            ifsc_code=payload.ifsc_code,
            upi_id=payload.upi_id,
            transaction_ids=payload.transaction_ids,
            amount_involved=payload.amount_involved,
            description=payload.description,
            status=ComplaintStatus.SUBMITTED,
        ).insert()

        return ComplaintResponse(
            complaint_id=complaint_id,
            status=ComplaintStatus.SUBMITTED,
            created_at=datetime.now(UTC).isoformat(),
            message="Complaint registered successfully",
        )


complaint_service = ComplaintService()