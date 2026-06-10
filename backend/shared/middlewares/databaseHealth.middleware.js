import mongoose from "mongoose";

export function databaseHealthMiddleware(req, res, next) {
  if (req.path === "/health" || req.path === "/database/status") {
    return next();
  }

  if (mongoose.connection.readyState !== 1) {
    return res.status(503).json({
      error: "DATABASE_UNAVAILABLE",
      message: "MongoDB Atlas connection is not available"
    });
  }

  return next();
}
