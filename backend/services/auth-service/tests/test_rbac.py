from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_rbac_middleware_checks_permissions_and_roles():
    source = (ROOT / "middleware" / "rbac_middleware.py").read_text(encoding="utf-8")
    assert "require_permissions" in source
    assert "require_roles" in source
    assert "SYSTEM_ADMIN" in source


def test_default_permissions_are_documented():
    docs = Path("docs/PHASE3_VERIFICATION_CHECKLIST.md").read_text(encoding="utf-8")
    assert "RBAC" in docs
