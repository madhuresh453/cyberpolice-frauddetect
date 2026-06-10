from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_auth_router_exposes_required_routes():
    source = (ROOT / "routers" / "auth.py").read_text(encoding="utf-8")
    for route in [
        '"/register"',
        '"/login"',
        '"/logout"',
        '"/refresh"',
        '"/change-password"',
        '"/forgot-password"',
        '"/reset-password"',
        '"/mfa/setup"',
        '"/mfa/verify"',
        '"/me"',
    ]:
        assert route in source


def test_argon2_and_jwt_are_used():
    auth_service = (ROOT / "services" / "auth_service.py").read_text(encoding="utf-8")
    token_service = (ROOT / "services" / "token_service.py").read_text(encoding="utf-8")
    assert 'schemes=["argon2"]' in auth_service
    assert "jwt.encode" in token_service
    assert "jwt.decode" in token_service
