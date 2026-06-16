import urllib.request
import json

# First try login with existing user
base = "http://localhost:5000/api/v1"

# Get registered users
try:
    req = urllib.request.Request(f"{base}/auth/login", 
        data=json.dumps({"email":"admin@cybershield.gov.in","password":"CyberShield@2026"}).encode(), 
        headers={"Content-Type":"application/json"})
    resp = urllib.request.urlopen(req)
    print("LOGIN SUCCESS:", resp.read().decode()[:200])
except urllib.error.HTTPError as e:
    print(f"LOGIN FAILED: {e.code} - {e.read().decode()[:200]}")

# Try another password
try:
    req = urllib.request.Request(f"{base}/auth/login", 
        data=json.dumps({"email":"admin@cybershield.gov.in","password":"CyberShield2026"}).encode(), 
        headers={"Content-Type":"application/json"})
    resp = urllib.request.urlopen(req)
    print("LOGIN SUCCESS:", resp.read().decode()[:200])
except urllib.error.HTTPError as e:
    print(f"LOGIN 2 FAILED: {e.code} - {e.read().decode()[:200]}")

# Health check
try:
    req = urllib.request.Request(f"{base.rstrip('/api/v1')}/health")
    resp = urllib.request.urlopen(req)
    print("HEALTH:", resp.read().decode())
except Exception as e:
    print(f"HEALTH FAILED: {e}")