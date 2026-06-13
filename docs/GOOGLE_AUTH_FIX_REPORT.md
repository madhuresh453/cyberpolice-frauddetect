# Google Auth Fix Report

## Root Cause

The previous implementation was returning stub values:

```json
{
  "access_token": "google_token_stub",
  "refresh_token": "google_refresh_stub"
}
```

These were not valid JWTs, causing `GET /auth/me` to fail with `401 INVALID_TOKEN`.

## Files Modified

### 1. `backend/shared/utils/google-auth.utils.js` (NEW)
Google OAuth verification utility using `google-auth-library`.

- **`verifyGoogleIdToken(idToken)`**: Verifies the Google ID token with Google's OAuth2 client
- Supports fallback for development when `GOOGLE_CLIENT_ID` is not set

### 2. `backend/shared/utils/auth.utils.js` (NEW)
Standardized auth utilities.

- **`generateAccessToken(user)`**: Creates real JWT with `sub`, `email`, `role`, `type: "access"` claims
- **`generateRefreshToken(user)`**: Creates real JWT with `sub`, `type: "refresh"` claims
- **`verifyToken(token)`**: Verifies JWT and returns payload
- **`buildAuthResponse(user, accessToken, refreshToken)`**: Builds standardized response

### 3. `backend/app.js` (REWRITTEN)
**`POST /api/v1/auth/google/login`** now:
- Accepts `{ id_token: "..." }`
- Calls `verifyGoogleIdToken()` to verify the token
- Finds existing user by email or googleId
- Creates new user if not found (with googleId linked)
- Returns real JWT access and refresh tokens
- Returns standardized response format

## Old Code (Broken)

```javascript
// app.js - OLD
app.post("/api/v1/auth/google/login", async (req, res) => {
  res.json({
    access_token: "google_token_stub",
    refresh_token: "google_refresh_stub",
    token_type: "bearer",
    expires_in: 900
  });
});
```

## New Code (Fixed)

```javascript
// app.js - NEW
app.post("/api/v1/auth/google/login", async (req, res, next) => {
  const googleUser = await verifyGoogleIdToken(id_token);

  // Find or create user
  if (!user) {
    user = await User.create({
      email,
      phoneNumber: "+1..." + googleUser.sub,
      passwordHash: placeholderPassword,
      fullName: displayName,
      googleId: googleUser.sub,
      role: "citizen",
      status: "active",
    });
  }

  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  res.json(buildAuthResponse(user, accessToken, refreshToken));
});
```

## Response Format (Standardized)

```json
{
  "success": true,
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "abc123...",
    "email": "user@gmail.com",
    "phoneNumber": "+916239015723",
    "fullName": "User Name",
    "role": "citizen",
    "status": "active"
  }
}