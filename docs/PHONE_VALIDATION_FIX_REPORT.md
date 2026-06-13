# Phone Validation Fix Report

## Root Cause

Flutter was sending `phone_number: "6239015723"` (raw 10-digit number without country code) while the backend expected `phoneNumber: "+916239015723"` (E.164 format). The validation in the Beanie ODM/Document layer required E.164 format and would reject any non-E.164 values.

## Files Modified

### 1. `backend/shared/utils/phone.utils.js` (NEW)
Phone number normalization utility using `libphonenumber-js`.

- **`normalizePhoneToE164(rawPhone)`**: Accepts `6239015723`, `+916239015723`, `919876543210` and converts to E.164.
- **`extractAndNormalizePhone(body, fieldName)`**: Maps `phone_number` (snake_case from Flutter) to `phoneNumber` (camelCase) and normalizes.

**Supported Countries**: India (IN), US/Canada (US), UK (GB), Australia (AU) via country code detection.

### 2. `backend/shared/models/User.model.js` (NEW)
Proper Mongoose User schema with:
- `phoneNumber` field stored in E.164 format
- Pre-save hook that auto-normalizes phone numbers
- Virtual `phone_number` getter for backward compatibility
- JSON transform that outputs `phone_number` for compatibility

### 3. `backend/app.js` (REWRITTEN)
**`POST /api/v1/auth/register`** now:
- Accepts both `phone_number` and `phoneNumber` field names
- Calls `extractAndNormalizePhone()` to auto-convert to E.164
- Returns standardized `{ success, accessToken, refreshToken, user }` response

### 4. `apps/citizen-mobile/lib/repositories/auth_repository.dart` (UPDATED)
- Added `_normalizePhone()` for client-side E.164 conversion
- Sends `phone_number` field (snake_case) consistently
- Handles both old `access_token` and new `accessToken` response keys

### 5. `apps/citizen-mobile/lib/screens/auth_screen.dart` (UPDATED)
- Added `_onPhoneChanged()` for real-time auto-formatting (`6239015723` → `+916239015723`)
- Added `_isValidEmail()`, `_isValidPhone()`, `_validatePassword()` validation functions
- Added `_normalizePhone()` for E.164 conversion before sending

## Old Code (Broken)

```javascript
// Backend - app.js (old register)
const user = await mongoose.models.User.create({
  phoneNumber: phone_number,  // Would fail if not E.164
  // ...
});
```

## New Code (Fixed)

```javascript
// Backend - app.js (new register)
const result = extractAndNormalizePhone(req.body, "phone_number");
phoneNumber = result.phoneNumber;  // Always E.164

const user = await User.create({
  phoneNumber,  // Stored as "+916239015723"
  // ...
});
```

## Verification

Input: `6239015723` → Normalized: `+916239015723` ✓
Input: `+916239015723` → Normalized: `+916239015723` ✓
Input: `919876543210` → Normalized: `+919876543210` ✓