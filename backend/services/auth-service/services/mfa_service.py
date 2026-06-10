import hashlib
import secrets

import pyotp


class MFAService:
    @staticmethod
    def generate_secret() -> str:
        return pyotp.random_base32()

    @staticmethod
    def provisioning_uri(email: str, secret: str) -> str:
        return pyotp.totp.TOTP(secret).provisioning_uri(name=email, issuer_name="CyberShield AI")

    @staticmethod
    def qr_svg(provisioning_uri: str) -> str:
        escaped = provisioning_uri.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
        return (
            '<svg xmlns="http://www.w3.org/2000/svg" width="420" height="80">'
            '<rect width="100%" height="100%" fill="white"/>'
            f'<text x="12" y="42" font-size="12" fill="black">{escaped}</text>'
            "</svg>"
        )

    @staticmethod
    def verify(secret: str, code: str) -> bool:
        return pyotp.TOTP(secret).verify(code, valid_window=1)

    @staticmethod
    def generate_recovery_codes(count: int = 10) -> list[str]:
        return [secrets.token_hex(5).upper() for _ in range(count)]

    @staticmethod
    def hash_recovery_code(code: str) -> str:
        return hashlib.sha256(code.strip().upper().encode("utf-8")).hexdigest()


mfa_service = MFAService()
