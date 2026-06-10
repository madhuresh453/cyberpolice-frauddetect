export function requestLogger(req, res, next) {
  const startedAt = Date.now();

  res.on("finish", () => {
    console.log(
      JSON.stringify({
        level: "info",
        message: "request completed",
        method: req.method,
        path: req.originalUrl,
        statusCode: res.statusCode,
        durationMs: Date.now() - startedAt,
        ip: req.ip,
        userAgent: req.get("user-agent") || null
      })
    );
  });

  next();
}
