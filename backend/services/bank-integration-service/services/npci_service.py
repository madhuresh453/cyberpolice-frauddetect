"""NPCI Service"""
from datetime import UTC, datetime
import uuid

from backend.shared.database.bank_documents import NPCRegistrationDocument
from ..schemas.bank_schemas import NPCIRegisterRequest, NPCIRegisterResponse


class NPCIService:
    async def register(self, payload: NPCIRegisterRequest, user) -> NPCIRegisterResponse:
        reference_id = f"NPCI-{uuid.uuid4().hex[:12].upper()}"
        registration = await NPCRegistrationDocument(
            npci_reference_id=reference_id,
            bank_name=payload.bank_name,
            bank_code=payload.bank_code,
            api_endpoint=payload.api_endpoint,
            api_key_hash=payload.api_key,
            is_active=True,
            last_sync_at=datetime.now(UTC),
            sync_status="registered",
        ).insert()

        return NPCIRegisterResponse(
            npci_reference_id=reference_id,
            bank_name=payload.bank_name,
            status="registered",
            message=f"Bank {payload.bank_name} registered with NPCI successfully",
        )

    async def submit_fraud_report(self, body: dict, user) -> dict:
        return {
            "status": "submitted",
            "reference_id": f"FR-{uuid.uuid4().hex[:12].upper()}",
            "message": "Fraud report submitted to NPCI",
        }


npci_service = NPCIService()