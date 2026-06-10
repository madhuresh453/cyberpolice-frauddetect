from datetime import datetime

from pydantic import BaseModel


class SessionRead(BaseModel):
    id: str
    device_fingerprint: str
    device_type: str
    ip_address: str
    user_agent: str
    location: dict
    status: str
    created_at: datetime
    last_seen_at: datetime
    expires_at: datetime
