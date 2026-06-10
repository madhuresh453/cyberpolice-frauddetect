"""Bank Integration MongoDB Documents"""
from datetime import UTC, datetime
from enum import StrEnum
from typing import Any

from beanie import Indexed
from pydantic import Field
from pymongo import ASCENDING, DESCENDING, IndexModel

from .base_document import BaseDocument


class FreezeStatus(StrEnum):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"
    RELEASED = "released"


class ComplaintStatus(StrEnum):
    SUBMITTED = "submitted"
    VERIFIED = "verified"
    INVESTIGATING = "investigating"
    RESOLVED = "resolved"
    DISMISSED = "dismissed"


class BankAccountDocument(BaseDocument):
    account_number: Indexed(str)
    ifsc_code: Indexed(str)
    bank_name: str
    account_holder_name: str
    phone_number: Indexed(str | None) = None
    upi_ids: list[str] = Field(default_factory=list)
    status: Indexed(str) = "active"
    risk_score: float = 0
    balance_frozen: bool = False
    frozen_at: datetime | None = None
    frozen_by: str | None = None
    freeze_reason: str | None = None
    complaints_count: int = 0
    last_transaction_at: datetime | None = None

    class Settings:
        name = "bank_accounts"
        indexes = [
            IndexModel([("account_number", ASCENDING), ("ifsc_code", ASCENDING)], unique=True),
            IndexModel([("phone_number", ASCENDING)]),
            IndexModel([("status", ASCENDING), ("risk_score", DESCENDING)]),
        ]


class FreezeRequestDocument(BaseDocument):
    request_id: Indexed(str, unique=True)
    account_number: str
    ifsc_code: str
    bank_name: str
    requested_by: str  # user_id
    requested_by_role: str
    reason: str
    freeze_type: str = "full"  # full, partial, emergency
    amount_to_freeze: float | None = None
    status: FreezeStatus = FreezeStatus.PENDING
    approved_by: str | None = None
    approved_at: datetime | None = None
    rejection_reason: str | None = None
    released_by: str | None = None
    released_at: datetime | None = None
    linked_case_id: str | None = None
    evidence_ids: list[str] = Field(default_factory=list)
    npci_reference: str | None = None
    bank_reference: str | None = None
    escalated_to_rbi: bool = False

    class Settings:
        name = "freeze_requests"
        indexes = [
            IndexModel([("status", ASCENDING), ("created_at", DESCENDING)]),
            IndexModel([("account_number", ASCENDING), ("ifsc_code", ASCENDING)]),
            IndexModel([("requested_by", ASCENDING)]),
        ]


class UPIVerificationDocument(BaseDocument):
    upi_id: Indexed(str, unique=True)
    upi_handle: str
    bank_name: str
    account_number_encrypted: str
    ifsc_code: str
    holder_name: str
    phone_number: str | None = None
    is_verified: bool = False
    verified_at: datetime | None = None
    risk_score: float = 0
    fraud_reports_count: int = 0
    last_transaction_at: datetime | None = None
    status: Indexed(str) = "active"

    class Settings:
        name = "upi_verifications"
        indexes = [
            IndexModel([("upi_id", ASCENDING)], unique=True),
            IndexModel([("phone_number", ASCENDING)]),
            IndexModel([("risk_score", DESCENDING)]),
        ]


class FraudComplaintDocument(BaseDocument):
    complaint_id: Indexed(str, unique=True)
    citizen_id: Indexed(str)
    complaint_type: str  # bank_fraud, upi_fraud, account_takeover, phishing
    account_number: str | None = None
    ifsc_code: str | None = None
    upi_id: str | None = None
    transaction_ids: list[str] = Field(default_factory=list)
    amount_involved: float = 0
    description: str
    status: ComplaintStatus = ComplaintStatus.SUBMITTED
    freeze_request_id: str | None = None
    assigned_bank_officer: str | None = None
    resolution_notes: str | None = None
    resolved_at: datetime | None = None
    linked_case_id: str | None = None
    evidence_urls: list[str] = Field(default_factory=list)

    class Settings:
        name = "fraud_complaints"
        indexes = [
            IndexModel([("citizen_id", ASCENDING), ("created_at", DESCENDING)]),
            IndexModel([("status", ASCENDING)]),
            IndexModel([("account_number", ASCENDING)]),
        ]


class NPCRegistrationDocument(BaseDocument):
    npci_reference_id: Indexed(str, unique=True)
    bank_name: str
    bank_code: str
    api_endpoint: str
    api_key_hash: str
    is_active: bool = True
    last_sync_at: datetime | None = None
    sync_status: str = "pending"
    fraud_reports_submitted: int = 0
    freeze_requests_processed: int = 0

    class Settings:
        name = "npci_registrations"
        indexes = [IndexModel([("bank_code", ASCENDING)], unique=True)]


class SuspiciousTransactionDocument(BaseDocument):
    transaction_id: Indexed(str, unique=True)
    account_number: str
    ifsc_code: str
    upi_id: str | None = None
    amount: float
    transaction_type: str  # credit, debit, transfer
    counterparty_account: str | None = None
    counterparty_ifsc: str | None = None
    counterparty_upi: str | None = None
    timestamp: datetime
    risk_score: float = 0
    risk_factors: list[str] = Field(default_factory=list)
    flagged_by: str = "system"
    status: Indexed(str) = "flagged"
    reviewed_by: str | None = None
    reviewed_at: datetime | None = None
    linked_freeze_id: str | None = None

    class Settings:
        name = "suspicious_transactions"
        indexes = [
            IndexModel([("account_number", ASCENDING), ("timestamp", DESCENDING)]),
            IndexModel([("risk_score", DESCENDING)]),
            IndexModel([("status", ASCENDING)]),
        ]