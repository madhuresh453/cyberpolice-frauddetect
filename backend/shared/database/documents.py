from datetime import UTC, datetime
from typing import Any

from beanie import Indexed
from pydantic import EmailStr, Field, field_validator
from pymongo import ASCENDING, DESCENDING, IndexModel

from .base_document import BaseDocument, RiskLevel, UserRole


class PermissionDocument(BaseDocument):
    code: Indexed(str, unique=True)
    name: str
    description: str = ""

    class Settings:
        name = "permissions"
        indexes = [IndexModel([("created_at", DESCENDING)])]


class RoleDocument(BaseDocument):
    name: Indexed(str, unique=True)
    description: str = ""
    role_type: UserRole
    permissions: list[str] = Field(default_factory=list)

    class Settings:
        name = "roles"
        indexes = [IndexModel([("role_type", ASCENDING), ("created_at", DESCENDING)])]


class UserDocument(BaseDocument):
    email: Indexed(EmailStr, unique=True)
    phone_number: Indexed(str, unique=True)
    password_hash: str
    full_name: str
    user_type: Indexed(UserRole)
    roles: list[str] = Field(default_factory=list)
    permissions: list[str] = Field(default_factory=list)
    status: Indexed(str) = "active"
    mfa_enabled: bool = False
    mfa_secret_encrypted: str | None = None
    recovery_code_hashes: list[str] = Field(default_factory=list)
    failed_login_attempts: int = 0
    locked_until: datetime | None = None
    last_login_at: datetime | None = None

    @field_validator("phone_number")
    @classmethod
    def validate_phone(cls, value: str) -> str:
        if not value.startswith("+") or not value[1:].isdigit() or len(value) < 9:
            raise ValueError("phone_number must be in E.164 format")
        return value

    class Settings:
        name = "users"
        indexes = [
            IndexModel([("status", ASCENDING), ("created_at", DESCENDING)]),
            IndexModel([("user_type", ASCENDING), ("status", ASCENDING)]),
        ]


class SessionDocument(BaseDocument):
    user_id: Indexed(str)
    refresh_token_hash: Indexed(str, unique=True)
    device_fingerprint: Indexed(str)
    device_type: str = "browser"
    ip_address: str
    user_agent: str
    location: dict[str, Any] = Field(default_factory=dict)
    status: Indexed(str) = "active"
    last_seen_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
    expires_at: Indexed(datetime)
    revoked_at: datetime | None = None

    class Settings:
        name = "sessions"
        indexes = [IndexModel([("user_id", ASCENDING), ("status", ASCENDING), ("created_at", DESCENDING)])]


class ApiKeyDocument(BaseDocument):
    owner_user_id: Indexed(str)
    name: str
    key_prefix: Indexed(str, unique=True)
    key_hash: Indexed(str, unique=True)
    scopes: list[str] = Field(default_factory=list)
    status: Indexed(str) = "active"
    expires_at: datetime | None = None
    last_used_at: datetime | None = None
    usage_count: int = 0

    class Settings:
        name = "api_keys"
        indexes = [IndexModel([("owner_user_id", ASCENDING), ("status", ASCENDING)])]


class CitizenDocument(BaseDocument):
    user_id: Indexed(str, unique=True)
    phone_number: Indexed(str, unique=True)
    preferred_language: str = "en"
    state: Indexed(str | None) = None
    district: str | None = None

    class Settings:
        name = "citizens"


class PoliceOfficerDocument(BaseDocument):
    user_id: Indexed(str, unique=True)
    badge_number: Indexed(str, unique=True)
    rank: str
    station_name: str
    district: Indexed(str)
    state: Indexed(str)

    class Settings:
        name = "police_officers"


class ISPOperatorDocument(BaseDocument):
    user_id: Indexed(str, unique=True)
    operator_code: Indexed(str)
    organization_name: str
    allowed_ip_ranges: list[str] = Field(default_factory=list)

    class Settings:
        name = "isp_operators"


class FraudReportDocument(BaseDocument):
    report_id: Indexed(str, unique=True)
    citizen_id: Indexed(str)
    phone_number: Indexed(str | None) = None
    upi_id: Indexed(str | None) = None
    status: Indexed(str) = "submitted"
    risk_score: Indexed(float) = 0
    description: str

    class Settings:
        name = "fraud_reports"


class AnalysisDocument(BaseDocument):
    report_id: Indexed(str | None) = None
    case_id: Indexed(str | None) = None
    phone_number: Indexed(str | None) = None
    upi_id: Indexed(str | None) = None
    risk_score: Indexed(float) = 0
    risk_level: RiskLevel = RiskLevel.SAFE
    model_version: str = "auth-phase3"
    findings: dict[str, Any] = Field(default_factory=dict)


class CallAnalysisDocument(AnalysisDocument):
    transcript: str | None = None

    class Settings:
        name = "call_analysis"


class SMSAnalysisDocument(AnalysisDocument):
    message: str | None = None

    class Settings:
        name = "sms_analysis"


class WhatsAppAnalysisDocument(AnalysisDocument):
    handle: str | None = None

    class Settings:
        name = "whatsapp_analysis"


class UPIAnalysisDocument(AnalysisDocument):
    amount_paise: int = 0

    class Settings:
        name = "upi_analysis"


class EvidenceDocument(BaseDocument):
    case_id: Indexed(str | None) = None
    report_id: Indexed(str | None) = None
    evidence_type: str
    storage_uri: str
    sha256: Indexed(str, unique=True)

    class Settings:
        name = "evidence"


class CaseDocument(BaseDocument):
    case_id: Indexed(str, unique=True)
    report_id: Indexed(str | None) = None
    status: Indexed(str) = "new"
    risk_score: Indexed(float) = 0
    assigned_officer_id: str | None = None
    title: str

    class Settings:
        name = "cases"


class NotificationDocument(BaseDocument):
    user_id: Indexed(str)
    status: Indexed(str) = "queued"
    title: str
    body: str
    channel: str = "push"

    class Settings:
        name = "notifications"


class BlockedNumberDocument(BaseDocument):
    phone_number: Indexed(str, unique=True)
    status: Indexed(str) = "active"
    risk_score: Indexed(float) = 100
    reason: str

    class Settings:
        name = "blocked_numbers"


class ThreatIntelligenceDocument(BaseDocument):
    indicator_type: Indexed(str)
    indicator_value: Indexed(str)
    risk_score: Indexed(float) = 0
    status: Indexed(str) = "active"
    source: str

    class Settings:
        name = "threat_intelligence"
        indexes = [IndexModel([("indicator_type", ASCENDING), ("indicator_value", ASCENDING)], unique=True)]


class FraudCampaignDocument(BaseDocument):
    campaign_id: Indexed(str, unique=True)
    status: Indexed(str) = "active"
    risk_score: Indexed(float) = 0
    name: str
    indicators: dict[str, Any] = Field(default_factory=dict)

    class Settings:
        name = "fraud_campaigns"


class AuditLogDocument(BaseDocument):
    actor_user_id: Indexed(str | None) = None
    actor_role: UserRole = UserRole.SYSTEM
    action: Indexed(str)
    resource: Indexed(str)
    resource_id: str | None = None
    ip_address: str | None = None
    user_agent: str | None = None
    before: dict[str, Any] | None = None
    after: dict[str, Any] | None = None

    class Settings:
        name = "audit_logs"
        indexes = [IndexModel([("resource", ASCENDING), ("resource_id", ASCENDING), ("created_at", DESCENDING)])]


class DigitalTrustScoreDocument(BaseDocument):
    subject_type: Indexed(str)
    subject_value: Indexed(str)
    risk_score: Indexed(float)
    status: Indexed(str) = "active"
    factors: dict[str, Any] = Field(default_factory=dict)

    class Settings:
        name = "digital_trust_scores"
        indexes = [IndexModel([("subject_type", ASCENDING), ("subject_value", ASCENDING)], unique=True)]


DOCUMENT_MODELS = [
    UserDocument,
    RoleDocument,
    PermissionDocument,
    SessionDocument,
    ApiKeyDocument,
    CitizenDocument,
    PoliceOfficerDocument,
    ISPOperatorDocument,
    FraudReportDocument,
    CallAnalysisDocument,
    SMSAnalysisDocument,
    WhatsAppAnalysisDocument,
    UPIAnalysisDocument,
    EvidenceDocument,
    CaseDocument,
    NotificationDocument,
    BlockedNumberDocument,
    ThreatIntelligenceDocument,
    FraudCampaignDocument,
    AuditLogDocument,
    DigitalTrustScoreDocument,
]
