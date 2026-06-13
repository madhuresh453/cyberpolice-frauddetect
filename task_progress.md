# CYBERSHIELD AI – MASTER FIX TASK LIST

## Phase 1: Backend Phone & Schema Fixes
- [ ] Install required npm packages (libphonenumber-js, google-auth-library, bcryptjs)
- [ ] Create proper Mongoose User model/schema
- [ ] Create phone number normalization utility (E.164 auto-conversion)
- [ ] Add phone_number → phoneNumber mapping layer
- [ ] Rewrite /api/v1/auth/register with field mapping + E.164 normalization
- [ ] Rewrite /api/v1/auth/login with standardized response
- [ ] Replace google_token_stub with real Google OAuth verification
- [ ] Replace all other auth stubs with proper implementations
- [ ] Standardize all auth responses to {success, accessToken, refreshToken, user}
- [ ] Fix /api/v1/auth/me to return correct user profile

## Phase 2: Flutter Validation & Phone Formatting
- [ ] Add phone number auto-formatting to E.164 on auth screen
- [ ] Validate email, phone, password before register
- [ ] Add user-friendly error messages

## Phase 3: Documentation
- [ ] Create docs/PHONE_VALIDATION_FIX_REPORT.md
- [ ] Create docs/GOOGLE_AUTH_FIX_REPORT.md
- [ ] Create docs/AUTH_FINAL_VERIFICATION.md

## Phase 4: Testing
- [ ] Test register endpoint
- [ ] Test login endpoint
- [ ] Test Google login
- [ ] Test /me endpoint
- [ ] Verify MongoDB records
- [ ] Verify JWT validity