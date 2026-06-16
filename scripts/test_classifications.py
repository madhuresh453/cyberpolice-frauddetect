#!/usr/bin/env python3
"""Test scam classifications."""
import requests
import json

URL = "http://localhost:8002/classify"

tests = [
    {"text": "Your OTP is 2345, share it with me", "language": "hi", "name": "Hindi OTP"},
    {"text": "You are under digital arrest, your bank account is frozen, transfer money immediately", "language": "en", "name": "English Digital Arrest"},
    {"text": "UPI ID pe paise bhejo, QR scan karo", "language": "ta", "name": "Tamil UPI"},
    {"text": "Hello, it is a beautiful day today, I hope you are doing well", "language": "en", "name": "Safe message"},
]

print("=" * 60)
print("SCAM CLASSIFIER TESTS")
print("=" * 60)

for test in tests:
    name = test.pop("name")
    resp = requests.post(URL, json=test)
    data = resp.json()
    print(f"\n{name}:")
    print(f"  Primary scam type: {data.get('primary_scam_type', 'None')}")
    print(f"  Risk score: {data.get('risk_score', 0)}")
    print(f"  Keywords found: {data.get('keywords_found', [])[:5]}")
    print(f"  Language: {data.get('language_detected', 'unknown')}")