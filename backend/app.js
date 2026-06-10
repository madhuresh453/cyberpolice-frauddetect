import express from "express";
import { databaseHealthMiddleware } from "./shared/middlewares/databaseHealth.middleware.js";
import { errorHandler } from "./shared/middlewares/errorHandler.middleware.js";
import { requestLogger } from "./shared/middlewares/requestLogger.middleware.js";
import healthRoutes from "./shared/routes/health.routes.js";

export function createApp() {
  const app = express();

  app.disable("x-powered-by");
  app.use(express.json({ limit: "1mb" }));
  app.use(requestLogger);
  app.use(databaseHealthMiddleware);
  app.use(healthRoutes);
  app.use(errorHandler);

  return app;
}
