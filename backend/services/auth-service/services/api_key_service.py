import hashlib
import secrets
from datetime import UTC, datetime

from backend.shared.database.documents import ApiKeyDocument


class APIKeyService:
    @staticmethod
    def hash_key(api_key: str) -> str:
        return hashlib.sha256(api_key.encode("utf-8")).hexdigest()

    async def issue(self, owner_user_id: str, name: str, scopes: list[str], expires_at=None) -> tuple[str, ApiKeyDocument]:
        secret = f"cs_{secrets.token_urlsafe(32)}"
        prefix = secret[:12]
        document = await ApiKeyDocument(
            owner_user_id=owner_user_id,
            name=name,
            key_prefix=prefix,
            key_hash=self.hash_key(secret),
            scopes=scopes,
            expires_at=expires_at,
        ).insert()
        return secret, document

    async def rotate(self, api_key_id: str) -> tuple[str, ApiKeyDocument]:
        document = await ApiKeyDocument.get(api_key_id)
        if not document or document.status != "active":
            raise ValueError("API key is not active")
        secret = f"cs_{secrets.token_urlsafe(32)}"
        document.key_prefix = secret[:12]
        document.key_hash = self.hash_key(secret)
        await document.save()
        return secret, document

    async def revoke(self, api_key_id: str) -> None:
        document = await ApiKeyDocument.get(api_key_id)
        if document:
            document.status = "revoked"
            document.updated_at = datetime.now(UTC)
            await document.save()


api_key_service = APIKeyService()
