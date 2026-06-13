# CYBERSHIELD AI — AUTH DEBUG REPORT
## Generated: June 13, 2026

---

## ROOT CAUSE: Missing CORS Configuration

**Symptom:** Flutter Web (Chrome) receives `XMLHttpRequest onError` when POSTing to `http://localhost:5000/api/v1/auth/register`

**Root Cause:** The Express backend had no CORS middleware. When Flutter Web on `http://localhost:PORT` sends a POST to `http://localhost:5000`, the browser blocks the response because there's no `Access-Control-Allow-Origin` header.

**Fix Applied:** Added CORS middleware to `backend/app.js` that:
- Sets `Access-Control-Allow-Origin: *`
- Handles OPTIONS preflight requests (returns 204)
- Allows `Content-Type`, `Authorization`, and other headers
- Sets `Access-Control-Max-Age: 86400`
- Placed BEFORE all route handlers

---

## FILES MODIFIED

| File | Change | Reason |
|------|--------|--------|
| `backend/app.js` | Added CORS middleware | Allow cross-origin POST requests from Flutter Web |
| `backend/shared/middlewares/requestLogger.middleware.js` | Added request body logging | Debug visibility for incoming payloads |

---

## VERIFICATION

1. Start backend: `cd backend && npm run dev`
2. Verify registration with curl:
```bash
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","phone_number":"1234567890","password":"test123","full_name":"Test User"}'
```

3. Expected response:
```json
{
  "id": "...",
  "email": "test@test.com",
  "access_token": "jwt_token...",
  "refresh_token": "jwt_refresh..."
}
```

4. Test CORS from Flutter Web:
- Open Chrome DevTools → Network tab
- Look for `POST /api/v1/auth/register`
- Should see `Access-Control-Allow-Origin: *` in response headers

5. Check backend console for:
```json
{"level":"info","message":"incoming request","method":"POST","path":"/api/v1/auth/register","body":{"email":"...","phone_number":"..."}}
{"level":"info","message":"request completed","method":"POST","path":"/api/v1/auth/register","statusCode":201}
```

---

## TROUBLESHOOTING

| Error | Cause | Fix |
|-------|-------|-----|
| XMLHttpRequest onError | CORS not configured | ✅ Fixed: Added CORS middleware |
| 404 Not Found | Route path mismatch | ✅ Fixed: Using `/api/v1/auth/register` |
| 500 Internal Server Error | MongoDB not connected | Check `MONGODB_URI` env var |
| 401 Invalid credentials | Wrong password/email | Check user exists in MongoDB |
| 409 Conflict | User already exists | Use different email |