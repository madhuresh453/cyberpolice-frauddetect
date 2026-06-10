"""Emergency Response MongoDB Documents"""
from datetime import UTC, datetime
from enum import StrEnum

from beanie import Indexed
from pydantic import Field
from pymongo import ASCENDING, DESCENDING, IndexModel

from .base_document import BaseDocument


class EmergencyStatus(StrEnum):
    ACTIVE = "active"
    RESPONDING = "responding"
    RESOLVED = "resolved"
    DISMISSED = "dismissed"


class EmergencyType(StrEnum):
    SOS = "sos"
    FRAUD_IN_PROGRESS = "fraud_in_progress"
    DEEPFAKE = "deepfake"
    PHISHING = "phishing"
    ACCOUNT_TAKEOVER = "account_takeover"
    UPI_FRAUD = "upi_fraud"
    BANK_FRAUD = "bank_fraud"
    IDENTITY_THEFT = "identity_theft"
    CYBER_STALKING = "cyber_stalking"


class EmergencySessionDocument(BaseDocument):
    session_id: Indexed(str, unique=True)
    citizen_id: Indexed(str)
    citizen_name: str
    citizen_phone: str
    citizen_email: str | None = None
    status: EmergencyStatus = EmergencyStatus.ACTIVE
    emergency_type: EmergencyType
    description: str | None = None
    location: dict | None = Field(default_factory=lambda: {"lat": 0, "lng": 0, "address": ""})
    device_info: dict | None = Field(default_factory=dict)
    call_recording_url: str | None = None
    screenshots: list[str] = Field(default_factory=list)
    sms_evidence: list[str] = Field(default_factory=list)
    whatsapp_evidence: list[str] = Field(default_factory=list)
    notified_police: bool = False
    police_station: str | None = None
    police_officer_id: str | None = None
    notified_family: bool = False
    family_members_notified: list[str] = Field(default_factory=list)
    notified_bank: bool = False
    bank_name: str | None = None
    freeze_requested: bool = False
    freeze_request_id: str | None = None
    fraud_report_id: str | None = None
    auto_generated_report: bool = False
    resolved_at: datetime | None = None
    resolved_by: str | None = None
    resolution_notes: str | None = None
    response_time_seconds: int | None = None
    linked_case_id: str | None = None

    class Settings:
        name = "emergency_sessions"
        indexes = [
            IndexModel([("citizen_id", ASCENDING), ("created_at", DESCENDING)]),
            IndexModel([("status", ASCENDING), ("created_at", DESCENDING)]),
            IndexModel([("linked_case_id", ASCENDING)]),
        ]


class EmergencyNotificationDocument(BaseDocument):
    session_id: Indexed(str)
    recipient_type: str  # police, family, bank, emergency_services
    recipient_id: str | None = None
    recipient_phone: str | None = None
    notification_type: str  # sms, push, email, voice_call
    message: str
    sent_at: datetime | None = None
    delivered: bool = False
    delivered_at: datetime | None = None
    response_received: bool = False
    response_data: dict | None = Field(default_factory=dict)

    class Settings:
        name = "emergency_notifications"
        indexes = [IndexModel([("session_id", ASCENDING), ("created_at", DESCENDING)])]


class EmergencyContactDocument(BaseDocument):
    citizen_id: Indexed(str)
    name: str
    phone_number: Indexed(str)
    relationship: str  # spouse, parent, child, sibling, friend
    is_primary: bool = False
    notification_enabled: bool = True
    verified: bool = False
    priority: int = 0

    class Settings:
        name = "emergency_contacts"
        indexes = [
            IndexModel([("citizen_id", ASCENDING)]),
            IndexModel([("citizen_id", ASCENDING), ("is_primary", ASCENDING)]),
        ]


class EvidenceCaptureDocument(BaseDocument):
    session_id: Indexed(str)
    evidence_type: str  # screenshot, recording, photo, video, document
    file_url: str
    file_hash: str
    file_size_bytes: int = 0
    mime_type: str
    captured_at: datetime
    synced: bool = False
    synced_at: datetime | None = None
    encrypted: bool = True
    integrity_verified: bool = False
    metadata: dict | None = Field(default_factory=dict)

    class Settings:
        name = "emergency_evidence"
        indexes = [
            IndexModel([("session_id", ASCENDING), ("captured_at", DESCENDING)]),
            IndexModel([("synced", ASCENDING)]),
        ]