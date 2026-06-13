export function errorHandler(error, req, res, _next) {
const statusCode = error.statusCode || error.status || 500;
  
  // Mongoose validation errors
  if (error.name === "ValidationError") {
    return res.status(400).json({
      error: "VALIDATION_ERROR",
      message: error.message,
      fields: Object.keys(error.errors).reduce((acc, key) => {
        acc[key] = error.errors[key].message;
        return acc;
      }, {})
    });
  }

  // Mongoose duplicate key errors
  if (error.code === 11000) {
    return res.status(409).json({
      error: "CONFLICT",
      message: "Duplicate key error",
      fields: Object.keys(error.keyPattern || {})
    });
  }

  // Mongoose strict mode errors
  if (error.name === "StrictModeError") {
    return res.status(400).json({
      error: "VALIDATION_ERROR",
      message: error.message
    });
  }

  // JWT errors
  if (error.name === "JsonWebTokenError" || error.name === "TokenExpiredError") {
    return res.status(401).json({
      error: "INVALID_TOKEN",
      message: error.message
    });
  }

  console.error(
    JSON.stringify({
      level: "error",
      message: "request failed",
      method: req.method,
      path: req.originalUrl,
      statusCode,
      error: error.message,
      stack: error.stack
    })
  );

  const payload = {
    error: error.code || "INTERNAL_SERVER_ERROR",
    message: error.message || "Internal server error"
  };

  res.status(statusCode).json(payload);
}
