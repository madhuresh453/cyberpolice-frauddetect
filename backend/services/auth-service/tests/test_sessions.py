from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_session_service_supports_revocation():
    source = (ROOT / "services" / "session_service.py").read_text(encoding="utf-8")
    assert "create_session" in source
    assert "revoke_session" in source
    assert "revoke_all" in source


def test_refresh_token_rotation_exists():
    source = (ROOT / "services" / "token_service.py").read_text(encoding="utf-8")
    assert "rotate_refresh_token" in source
    assert "create_refresh_token" in source
    assert "hash_token" in source
