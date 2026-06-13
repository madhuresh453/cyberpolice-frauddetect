export function requestLogger(req, res, next) {
  const startedAt = Date.now();

  // Log incoming request
  console.log(
    JSON.stringify({
      level: "info",
      message: "incoming request",
      method: req.method,
      path: req.originalUrl,
      contentType: req.get("content-type") || null,
      body: req.method !== "GET" ? req.body : undefined,
      ip: req.ip,
    })
  );

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
      })
    );
  });

  next();
}