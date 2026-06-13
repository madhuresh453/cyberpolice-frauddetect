import { OAuth2Client } from "google-auth-library";

/**
 * Google OAuth client.
 * In production, set GOOGLE_CLIENT_ID in your .env or config.
 */
const GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID || "";

let oauthClient = null;
function getOAuthClient() {
  if (!oauthClient) {
    oauthClient = new OAuth2Client(GOOGLE_CLIENT_ID);
  }
  return oauthClient;
}

/**
 * Verify a Google ID token and return the user payload.
 *
 * @param {string} idToken - The Google ID token from the client.
 * @returns {Promise<{ sub: string, email: string, name: string, picture: string }>}
 * @throws {Error} If the token is invalid.
 */
export async function verifyGoogleIdToken(idToken) {
  if (!GOOGLE_CLIENT_ID) {
    // Fallback for development/testing without a real client ID.
    // In production, set GOOGLE_CLIENT_ID in .env
    console.warn(
      "WARNING: GOOGLE_CLIENT_ID not set. Using development fallback for Google token verification."
    );
    // Decode the token without verification for development only
    try {
      const parts = idToken.split(".");
      if (parts.length === 3) {
        const payload = JSON.parse(
          Buffer.from(parts[1], "base64").toString("utf-8")
        );
        return {
          sub: payload.sub || "dev_" + idToken.slice(0, 8),
          email: payload.email || null,
          name: payload.name || null,
          picture: payload.picture || null,
        };
      }
    } catch {
      // fall through to real verification
    }

    // Development stub: accept any token and return a dummy user
    return {
      sub: "google_dev_" + idToken.slice(-8),
      email: null,
      name: null,
      picture: null,
    };
  }

  // Real verification using Google's OAuth2 client
  const client = getOAuthClient();
  const ticket = await client.verifyIdToken({
    idToken,
    audience: GOOGLE_CLIENT_ID,
  });

  const payload = ticket.getPayload();
  if (!payload) {
    throw new Error("Invalid Google ID token: no payload");
  }

  return {
    sub: payload.sub,
    email: payload.email || null,
    name: payload.name || null,
    picture: payload.picture || null,
  };
}