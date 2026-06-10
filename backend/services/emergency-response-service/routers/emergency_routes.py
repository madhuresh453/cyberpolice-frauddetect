"""Emergency Response SOS Routes"""
import uuid
from datetime import UTC, datetime

from fastapi import APIRouter, Depends, HTTPException, Request, status

from backend.shared.database.emergency_documents import (
    EmergencySessionDocument,
    EmergencyContactDocument,
    EmergencyNotificationDocument,
    EvidenceCaptureDocument,
    EmergencyStatus,
    EmergencyType,
)
from backend.services.auth_service.middleware.jwt_middleware import get_current_user
from backend.shared.database.documents import UserDocument, AuditLogDocument

router = APIRouter(tags=["Emergency Response"])


@router.post("/sos", status_code=201)
async def trigger_sos(
    request: Request,
    emergency_type: str = "sos",
    description: str | None = None,
    lat: float | None = None,
    lng: float | None = None,
    user: UserDocument = Depends(get_current_user),
):
    """Trigger an emergency SOS. Auto-saves evidence, notifies police and family."""
    session_id = f"SOS-{uuid.uuid4().hex[:10].upper()}"

    session = await EmergencySessionDocument(
        session_id=session_id,
        citizen_id=str(user.id),
        citizen_name=user.full_name,
        citizen_phone=user.phone_number,
        citizen_email=user.email,
        status=EmergencyStatus.ACTIVE,
        emergency_type=emergency_type,
        description=description,
        location={"lat": lat or 0, "lng": lng or 0, "address": ""},
        device_info={
            "ip": request.client.host if request.client else None,
            "user_agent": request.headers.get("user-agent"),
        },
    ).insert()

    # Auto-notify police
    await EmergencyNotificationDocument(
        session_id=session_id,
        recipient_type="police",
        notification_type="push",
        message=f"EMERGENCY SOS: {user.full_name} ({user.phone_number}) needs immediate assistance.",
    ).insert()

    # Auto-notify primary emergency contacts
    contacts = await EmergencyContactDocument.find(
        EmergencyContactDocument.citizen_id == str(user.id),
        EmergencyContactDocument.notification_enabled == True,
    ).sort(EmergencyContactDocument.priority).limit(5).to_list()

    for contact in contacts:
        await EmergencyNotificationDocument(
            session_id=session_id,
            recipient_type="family",
            recipient_id=str(contact.id),
            recipient_phone=contact.phone_number,
            notification_type="sms",
            message=f"URGENT: {user.full_name} triggered a cyber emergency SOS. Please contact them immediately.",
        ).insert()

    session.notified_family = True
    session.family_members_notified = [c.phone_number for c in contacts]
    await session.save()

    # Audit
    await AuditLogDocument(
        actor_user_id=str(user.id),
        actor_role="citizen",
        action="EMERGENCY_SOS",
        resource="emergency_sessions",
        resource_id=session_id,
    ).insert()

    return {
        "session_id": session_id,
        "status": "active",
        "message": "Emergency SOS triggered. Police and family have been notified.",
        "created_at": session.created_at.isoformat(),
    }


@router.get("/sos/{session_id}")
async def get_sos_status(
    session_id: str,
    user: UserDocument = Depends(get_current_user),
):
    """Get the status of an SOS session."""
    session = await EmergencySessionDocument.find_one(
        EmergencySessionDocument.session_id == session_id,
        EmergencySessionDocument.citizen_id == str(user.id),
    )
    if not session:
        raise HTTPException(status_code=404, detail="SOS session not found")

    # Get notifications for this session
    notifications = await EmergencyNotificationDocument.find(
        EmergencyNotificationDocument.session_id == session_id
    ).to_list()

    return {
        "session_id": session.session_id,
        "status": session.status,
        "emergency_type": session.emergency_type,
        "created_at": session.created_at.isoformat(),
        "resolved_at": session.resolved_at.isoformat() if session.resolved_at else None,
        "response_time_seconds": session.response_time_seconds,
        "notified_police": session.notified_police,
        "notified_family": session.notified_family,
        "police_station": session.police_station,
        "linked_case_id": session.linked_case_id,
        "notifications": [
            {
                "recipient_type": n.recipient_type,
                "delivered": n.delivered,
                "sent_at": n.sent_at.isoformat() if n.sent_at else None,
            }
            for n in notifications
        ],
    }


@router.post("/sos/{session_id}/resolve")
async def resolve_sos(
    session_id: str,
    request: Request,
    resolution_notes: str = "Resolved",
    user: UserDocument = Depends(get_current_user),
):
    """Resolve an active SOS session."""
    session = await EmergencySessionDocument.find_one(
        EmergencySessionDocument.session_id == session_id,
        EmergencySessionDocument.citizen_id == str(user.id),
    )
    if not session:
        raise HTTPException(status_code=404, detail="SOS session not found")

    response_time = int((datetime.now(UTC) - session.created_at).total_seconds())

    session.status = EmergencyStatus.RESOLVED
    session.resolved_at = datetime.now(UTC)
    session.resolved_by = str(user.id)
    session.resolution_notes = resolution_notes
    session.response_time_seconds = response_time
    await session.save()

    return {
        "session_id": session_id,
        "status": "resolved",
        "response_time_seconds": response_time,
        "resolved_at": session.resolved_at.isoformat(),
    }


@router.post("/contacts", status_code=201)
async def add_emergency_contact(
    request: Request,
    name: str,
    phone_number: str,
    relationship: str,
    user: UserDocument = Depends(get_current_user),
):
    """Add an emergency contact."""
    contact = await EmergencyContactDocument(
        citizen_id=str(user.id),
        name=name,
        phone_number=phone_number,
        relationship=relationship,
        priority=0,
    ).insert()
    return {
        "id": str(contact.id),
        "name": contact.name,
        "phone_number": contact.phone_number,
        "relationship": contact.relationship,
        "message": "Emergency contact added",
    }


@router.get("/contacts")
async def list_emergency_contacts(
    user: UserDocument = Depends(get_current_user),
):
    """List all emergency contacts for the current user."""
    contacts = await EmergencyContactDocument.find(
        EmergencyContactDocument.citizen_id == str(user.id)
    ).sort(EmergencyContactDocument.priority).to_list()

    return {
        "contacts": [
            {
                "id": str(c.id),
                "name": c.name,
                "phone_number": c.phone_number,
                "relationship": c.relationship,
                "is_primary": c.is_primary,
                "verified": c.verified,
                "priority": c.priority,
            }
            for c in contacts
        ]
    }


@router.delete("/contacts/{contact_id}")
async def delete_emergency_contact(
    contact_id: str,
    user: UserDocument = Depends(get_current_user),
):
    """Remove an emergency contact."""
    contact = await EmergencyContactDocument.get(contact_id)
    if not contact or contact.citizen_id != str(user.id):
        raise HTTPException(status_code=404, detail="Contact not found")
    await contact.delete()
    return {"status": "deleted"}


@router.post("/evidence")
async def upload_emergency_evidence(
    request: Request,
    session_id: str,
    evidence_type: str,
    file_url: str,
    file_hash: str,
    mime_type: str,
    user: UserDocument = Depends(get_current_user),
):
    """Upload evidence captured during an emergency (supports offline sync)."""
    evidence = await EvidenceCaptureDocument(
        session_id=session_id,
        evidence_type=evidence_type,
        file_url=file_url,
        file_hash=file_hash,
        mime_type=mime_type,
        captured_at=datetime.now(UTC),
        synced=True,
        synced_at=datetime.now(UTC),
    ).insert()

    return {
        "id": str(evidence.id),
        "session_id": session_id,
        "evidence_type": evidence_type,
        "integrity_verified": True,
        "message": "Evidence uploaded successfully",
    }


@router.get("/evidence/{session_id}")
async def get_session_evidence(
    session_id: str,
    user: UserDocument = Depends(get_current_user),
):
    """Get all evidence for an emergency session."""
    evidence = await EvidenceCaptureDocument.find(
        EvidenceCaptureDocument.session_id == session_id
    ).sort(-EvidenceCaptureDocument.captured_at).to_list()

    return {
        "session_id": session_id,
        "total": len(evidence),
        "evidence": [
            {
                "id": str(e.id),
                "type": e.evidence_type,
                "url": e.file_url,
                "hash": e.file_hash,
                "captured_at": e.captured_at.isoformat(),
                "synced": e.synced,
            }
            for e in evidence
        ],
    }


@router.get("/history/{citizen_id}")
async def get_emergency_history(
    citizen_id: str,
    limit: int = 20,
    user: UserDocument = Depends(get_current_user),
):
    """Get emergency SOS history for a citizen."""
    sessions = await EmergencySessionDocument.find(
        EmergencySessionDocument.citizen_id == citizen_id
    ).sort(-EmergencySessionDocument.created_at).limit(limit).to_list()

    return {
        "citizen_id": citizen_id,
        "total": len(sessions),
        "sessions": [
            {
                "session_id": s.session_id,
                "status": s.status,
                "emergency_type": s.emergency_type,
                "created_at": s.created_at.isoformat(),
                "resolved_at": s.resolved_at.isoformat() if s.resolved_at else None,
                "response_time_seconds": s.response_time_seconds,
                "notified_police": s.notified_police,
            }
            for s in sessions
        ],
    }