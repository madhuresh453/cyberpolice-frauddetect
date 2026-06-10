from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_mfa_service_uses_totp_and_recovery_codes():
    source = (ROOT / "services" / "mfa_service.py").read_text(encoding="utf-8")
    assert "pyotp" in source
    assert "generate_recovery_codes" in source
    assert "hash_recovery_code" in source


def test_mfa_routes_exist():
    source = (ROOT / "routers" / "auth.py").read_text(encoding="utf-8")
    assert "/mfa/setup" in source
    assert "/mfa/verify" in source
