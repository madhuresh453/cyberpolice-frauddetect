import { parsePhoneNumber, isPossiblePhoneNumber } from "libphonenumber-js";

/**
 * Country codes mapped to their ISO country codes for default parsing.
 */
const DEFAULT_COUNTRY_MAP = {
  "91": "IN", // India
  "1": "US",  // US/Canada
  "44": "GB", // UK
  "61": "AU", // Australia
};

/**
 * Try to detect the country code from the phone number.
 * If the number starts with a known country code, return the ISO country.
 */
function detectCountry(phoneNumber) {
  const cleaned = phoneNumber.replace(/[^0-9+]/g, "");
  for (const [code, country] of Object.entries(DEFAULT_COUNTRY_MAP)) {
    if (cleaned.startsWith(`+${code}`)) {
      return country;
    }
  }
  // Default to India if no match
  return "IN";
}

/**
 * Normalize a phone number to E.164 format.
 *
 * Accepts:
 *   "6239015723"       → "+916239015723"  (assumes India)
 *   "919876543210"     → "+919876543210"
 *   "+916239015723"    → "+916239015723"  (already E.164)
 *   "16239015723"      → "+16239015723"   (US number)
 *
 * @param {string} phoneNumber - The raw phone number input.
 * @returns {string} The phone number in E.164 format.
 * @throws {Error} If the phone number cannot be parsed.
 */
export function normalizePhoneToE164(phoneNumber) {
  if (!phoneNumber || typeof phoneNumber !== "string") {
    throw new Error("Phone number is required");
  }

  const cleaned = phoneNumber.replace(/[^0-9+]/g, "");

  // If already in E.164 format, validate and return
  if (cleaned.startsWith("+")) {
    if (isPossiblePhoneNumber(cleaned)) {
      return cleaned;
    }
    throw new Error(`Invalid phone number: ${phoneNumber}`);
  }

  // If the number starts with a country code (e.g., 91 for India)
  // try to parse with the detected country
  const defaultCountry = detectCountry(cleaned);

  try {
    const parsed = parsePhoneNumber(cleaned, defaultCountry);
    if (parsed && parsed.isValid()) {
      return parsed.number; // E.164 format
    }
  } catch {
    // Fall through to error
  }

  // Last resort: prefix with + and hope it works
  // This handles edge cases where libphonenumber-js might not recognize
  if (cleaned.length >= 10 && cleaned.length <= 15) {
    const e164 = `+${cleaned}`;
    if (isPossiblePhoneNumber(e164)) {
      return e164;
    }
  }

  throw new Error(
    `Cannot normalize phone number: "${phoneNumber}". Provide a valid phone number with country code.`
  );
}

/**
 * Map a phone_number field from snake_case (Flutter sends) to phoneNumber
 * and normalize to E.164.
 *
 * @param {object} body - The request body.
 * @param {string} [fieldName="phone_number"] - The field name to look for.
 * @returns {object} - { phoneNumber: "E.164 string" }
 */
export function extractAndNormalizePhone(body, fieldName = "phone_number") {
  // Accept both snake_case and camelCase
  const rawPhone = body[fieldName] || body.phoneNumber || body.phone_number;

  if (!rawPhone) {
    throw new Error(`Phone number field "${fieldName}" or "phoneNumber" is required`);
  }

  const phoneNumber = normalizePhoneToE164(String(rawPhone));

  return { phoneNumber };
}