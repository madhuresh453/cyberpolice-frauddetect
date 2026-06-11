import jwt from "jsonwebtoken";
import { config } from "../database/database.config.js";

export function authenticateJWT(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "AUTH_REQUIRED", message: "Bearer token required" });
  }
  try {
    const token = authHeader.split(" ")[1];
    const payload = jwt.verify(token, config.jwtSecret);
    req.user = payload;
    next();
  } catch (error) {
    return res.status(401).json({ error: "INVALID_TOKEN", message: "Invalid or expired token" });
  }
}

export function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: "AUTH_REQUIRED", message: "Authentication required" });
    }
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: "FORBIDDEN", message: `Requires one of roles: ${roles.join(", ")}` });
    }
    next();
  };
}