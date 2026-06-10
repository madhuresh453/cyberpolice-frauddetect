export function errorHandler(error, req, res, _next) {
  const statusCode = error.statusCode || error.status || 500;
  const payload = {
    error: error.code || "INTERNAL_SERVER_ERROR",
    message: statusCode >= 500 ? "Internal server error" : error.message
  };

  console.error(
    JSON.stringify({
      level: "error",
      message: "request failed",
      method: req.method,
      path: req.originalUrl,
      statusCode,
      error: error.message,
      stack: process.env.NODE_ENV === "production" ? undefined : error.stack
    })
  );

  res.status(statusCode).json(payload);
}
