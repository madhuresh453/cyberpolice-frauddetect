# CYBERSHIELD AI — AUTH ROUTE AUDIT
## Generated: June 13, 2026

---

## ROUTE VERIFICATION

| Route | Backend Path | Flutter Endpoint | Full URL | Status |
|-------|-------------|-----------------|----------|--------|
| Register | `POST /api/v1/auth/register` | `/auth/register` | `http://localhost:5000/api/v1/auth/register` | ✅ Match |
| Login | `POST /api/v1/auth/login` | `/auth/login` | `http://localhost:5000/api/v1/auth/login` | ✅ Match |
| Logout | `POST /api/v1/auth/logout` | `/auth/logout` | `http://localhost:5000/api/v1/auth/logout` | ✅ Match |
| Refresh | `POST /api/v1/auth/refresh` | `/auth/refresh` | `http://localhost:5000/api/v1/auth/refresh` | ✅ Match |
| Me | `GET /api/v1/auth/me` | `/auth/me` | `http://localhost:5000/api/v1/auth/me` | ✅ Match |

---

## REQUEST PAYLOAD VERIFICATION

### Register (Flutter → Backend)

**Flutter sends:**
```dart
final response = await _api.post(ApiEndpoints.register, data: {
  'email': email,
  'phone_number': phone,
  'password': password,
  'full_name': name,
  'user_type': 'citizen',
});
```

**Backend expects:**
```javascript
const { email, phone_number, password, full_name, user_type } = req.body;
```

**Result:** ✅ Match

### Login (Flutter → Backend)

**Flutter sends:**
```dart
final response = await _api.post(ApiEndpoints.login, data: {
  'email': email,
  'password': password,
});
```

**Backend expects:**
```javascript
const { email, password } = req.body;
```

**Result:** ✅ Match

---

## RESPONSE PAYLOAD VERIFICATION

### Register Response

**Backend returns:**
```json
{
  "id": "...",
  "email": "...",
  "phone_number": "...",
  "full_name": "...",
  "role": "citizen",
  "status": "active",
  "created_at": "...",
  "access_token": "jwt_token...",
  "refresh_token": "jwt_refresh...",
  "token_type": "bearer",
  "expires_in": 900
}
```

**Flutter parses:**
```dart
final data = response.data as Map<String, dynamic>;
if (data.containsKey('access_token') || data.containsKey('tokens')) {
  await _handleAuthResponse(data);
}
return UserModel.fromJson(data);
```

**Result:** ✅ Match — Flutter checks for `access_token`, stores it, then fetches `/auth/me`

### Login Response

**Backend returns:**
```json
{
  "access_token": "jwt_token...",
  "refresh_token": "jwt_refresh...",
  "token_type": "bearer",
  "expires_in": 900
}
```

**Flutter parses:**
```dart
final data = response.data as Map<String, dynamic>;
await _handleAuthResponse(data);
final userResponse = await _api.get(ApiEndpoints.me);
return UserModel.fromJson(userResponse.data as Map<String, dynamic>);
```

**Result:** ✅ Match — Flutter stores tokens, then fetches user from `/auth/me`

---

## CORS CONFIGURATION

```javascript
import cors from "cors";

app.use(cors({
  origin: true,
  credentials: true,
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization", "Accept", "X-Requested-With"]
}));
```

**Status:** ✅ Properly configured before all routes

---

## TESTING COMMANDS

### Test Register
```bash
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","phone_number":"1234567890","password":"test123","full_name":"Test User","user_type":"citizen"}'
```

### Test Login
```bash
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123"}'
```

### Test CORS
```bash
curl -I -X OPTIONS http://localhost:5000/api/v1/auth/register \
  -H "Origin: http://localhost:8080" \
  -H "Access-Control-Request-Method: POST"
```

---

## FLUTTER FILE VERIFICATION

| File | Status | Notes |
|------|--------|-------|
| `api_client.dart` | ✅ | Uses `AppConstants.apiBaseUrl` which resolves to `http://localhost:5000/api/v1` for web |
| `auth_repository.dart` | ✅ | Sends correct payload, parses response correctly |
| `auth_provider.dart` | ✅ | Calls repository methods correctly |
| `constants.dart` | ✅ | Endpoints match backend routes |
| `environment.dart` | ✅ | No dart:io import, uses kIsWeb |