"""Bank Integration Pydantic Schemas"""
from datetime import datetime

from pydantic import BaseModel, Field


class AccountLookupRequest(BaseModel):
    account_number: str | None = None
    ifsc_code: str | None = None
    phone_number: str | None = None


class AccountLookupResponse(BaseModel):
    account_number: str
    ifsc_code: str
    bank_name: str
    account_holder_name: str
    status: str
    risk_score: float
    balance_frozen: bool
    complaints_count: int
    upi_ids: list[str]


class FreezeAccountRequest(BaseModel):
    account_number: str
    ifsc_code: str
    bank_name: str
    reason: str = Field(min_length=10)
    freeze_type: str = "full"
    amount_to_freeze: float | None = None
    linked_case_id: str | None = None
    evidence_ids: list[str] = Field(default_factory=list)


class FreezeAccountResponse(BaseModel):
    request_id: str
    account_number: str
    ifsc_code: str
    bank_name: str
    freeze_type: str
    status: str
    created_at: str
    message: str


class ComplaintCreateRequest(BaseModel):
    complaint_type: str
    account_number: str | None = None
    ifsc_code: str | None = None
    upi_id: str | None = None
    transaction_ids: list[str] = Field(default_factory=list)
    amount_involved: float = 0
    description: str = Field(min_length=20)
    evidence_urls: list[str] = Field(default_factory=list)


class ComplaintResponse(BaseModel):
    complaint_id: str
    status: str
    created_at: str
    message: str


class TransactionQueryResponse(BaseModel):
    account_number: str
    total: int
    transactions: list[dict]


class UPIVerifyRequest(BaseModel):
    upi_id: str


class UPIVerifyResponse(BaseModel):
    upi_id: str
    upi_handle: str
    bank_name: str
    holder_name: str
    is_verified: bool
    risk_score: float
    fraud_reports_count: int


class NPCIRegisterRequest(BaseModel):
    bank_name: str
    bank_code: str
    api_endpoint: str
    api_key: str


class NPCIRegisterResponse(BaseModel):
    npci_reference_id: str
    bank_name: str
    status: str
    message: str


class EmergencyHoldRequest(BaseModel):
    account_number: str
    ifsc_code: str
    bank_name: str
    citizen_id: str
    citizen_phone: str
    emergency_session_id: str
    reason: str = "Emergency cyber fraud hold"