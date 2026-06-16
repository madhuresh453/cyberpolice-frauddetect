"""UPI Verification Service"""
from fastapi import HTTPException
from backend.shared.database.bank_documents import UPIVerificationDocument
from ..schemas.bank_schemas import UPIVerifyRequest, UPIVerifyResponse


class UPIService:
    async def verify_upi(self, payload: UPIVerifyRequest, user) -> UPIVerifyResponse:
        upi_record = await UPIVerificationDocument.find_one({"upi_id": payload.upi_id})
        if not upi_record:
            raise HTTPException(status_code=404, detail="UPI ID not found")
        return UPIVerifyResponse(
            upi_id=upi_record.upi_id,
            upi_handle=upi_record.upi_handle,
            bank_name=upi_record.bank_name,
            holder_name=upi_record.holder_name,
            is_verified=upi_record.is_verified,
            risk_score=upi_record.risk_score,
            fraud_reports_count=upi_record.fraud_reports_count,
        )

    async def get_upi_risk(self, upi_id: str) -> dict:
        upi_record = await UPIVerificationDocument.find_one({"upi_id": upi_id})
        if not upi_record:
            return {"upi_id": upi_id, "risk_score": 0.0, "fraud_reports_count": 0}
        return {
            "upi_id": upi_record.upi_id,
            "risk_score": upi_record.risk_score,
            "fraud_reports_count": upi_record.fraud_reports_count,
        }


upi_service = UPIService()