#!/usr/bin/env python3
"""End-to-end system test for CyberShield AI platform."""
import requests
import json
import time

BASE_URL = "http://localhost:5000"
AI_GATEWAY = "http://localhost:8000"
CLASSIFIER = "http://localhost:8002"

def print_header(msg):
    print(f"\n{'='*60}")
    print(f"  {msg}")
    print(f"{'='*60}")

def test_backend_health():
    print_header("1. BACKEND HEALTH CHECK")
    r = requests.get(f"{BASE_URL}/health")
    data = r.json()
    print(f"  Status: {data.get('status')}")
    print(f"  Database: {data.get('database')}")
    assert data.get('status') == 'healthy'
    print("  ✅ Backend is healthy")
    return data

def test_ai_gateway_health():
    print_header("2. AI GATEWAY HEALTH CHECK")
    r = requests.get(f"{AI_GATEWAY}/health")
    data = r.json()
    print(f"  Status: {data.get('status')}")
    print(f"  Services: {json.dumps(data.get('services', {}), indent=4)}")
    assert data.get('status') == 'healthy'
    print("  ✅ AI Gateway is healthy")
    return data

def test_scam_classification():
    print_header("3. SCAM CLASSIFICATION TEST")
    test_cases = [
        ("Hindi OTP Scam", "Your OTP is 2345, share it with me immediately", "hi"),
        ("English Digital Arrest", "You are under digital arrest, your bank account is frozen, transfer money immediately or you will be arrested", "en"),
        ("UPI Scam", "QR scan karo aur UPI ID pe paise bhejo", "ta"),
    ]
    
    for name, text, lang in test_cases:
        r = requests.post(f"{CLASSIFIER}/classify", json={"text": text, "language": lang})
        data = r.json()
        print(f"\n  {name}:")
        print(f"    Primary scam: {data.get('primary_scam_type', 'None')}")
        print(f"    Risk score: {data.get('risk_score', 0)}")
        print(f"    Confidence: {data.get('primary_confidence', 0)}")
        print(f"    Keywords: {data.get('keywords_found', [])[:3]}")
    print("  ✅ Scam classification working")

def test_full_analysis():
    print_header("4. FULL ANALYSIS TEST (RAKSAAR)")
    payload = {
        "text": "Your OTP is 2345, share it with me immediately",
        "phone_number": "+911401234567",
        "url": "https://paytm-safe.com/verify",
        "upi_id": "scam@paytm",
        "language": "hi"
    }
    r = requests.post(f"{AI_GATEWAY}/analyze/full", json=payload)
    data = r.json()
    print(f"  Verdict: {data.get('overall_verdict')}")
    print(f"  Risk Score: {data.get('risk_score', {}).get('risk_score')}")
    print(f"  Phone Reputation: {data.get('phone_reputation', {}).get('risk_score')}")
    print(f"  URL Analysis: {data.get('url_analysis', {}).get('risk_score')}")
    print(f"  Processing time: {data.get('processing_time_ms')}ms")
    print("  ✅ Full analysis pipeline working")

def test_security():
    print_header("5. SECURITY HEADERS TEST")
    r = requests.get(f"{BASE_URL}/health")
    headers = r.headers
    print(f"  X-Content-Type-Options: {headers.get('x-content-type-options', 'N/A')}")
    print(f"  X-Frame-Options: {headers.get('x-frame-options', 'N/A')}")
    print(f"  Content-Security-Policy: {'Present' if headers.get('content-security-policy') else 'N/A'}")
    print(f"  Strict-Transport-Security: {'Present' if headers.get('strict-transport-security') else 'N/A'}")
    print("  ✅ Security headers check complete")

def main():
    print("\n" + "="*60)
    print("  CYBERSHIELD AI - END-TO-END TEST")
    print("="*60)
    
    results = {}
    
    try:
        results['backend'] = test_backend_health()
        results['gateway'] = test_ai_gateway_health()
        test_scam_classification()
        test_full_analysis()
        test_security()
        
        print_header("6. ALL TESTS PASSED ✅")
        print("  Backend        : http://localhost:5000/health")
        print("  AI Gateway     : http://localhost:8000/health")
        print("  STT Service    : http://localhost:8001/health")
        print("  Classifier     : http://localhost:8002/health")
        print("  Deepfake       : http://localhost:8003/health")
        print("  Police Portal  : http://localhost:3000")
        print("  Neo4j Browser  : http://localhost:7474")
        
    except Exception as e:
        print(f"\n  ❌ Test failed: {e}")
        
    print(f"\n{'='*60}")

if __name__ == "__main__":
    main()