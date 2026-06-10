import { Router } from "express";
import { getDatabaseHealth } from "../database/healthcheck.js";
import { mongoDBService } from "../services/mongodb.service.js";

const router = Router();

router.get("/health", async (_req, res, next) => {
  try {
    const health = await getDatabaseHealth();
    res.status(health.connected ? 200 : 503).json({
      status: health.connected ? "healthy" : "unhealthy",
      database: health.connected ? "connected" : "disconnected"
    });
  } catch (error) {
    next(error);
  }
});

router.get("/database/status", async (_req, res, next) => {
  try {
    res.json(await mongoDBService.connectionSummary());
  } catch (error) {
    next(error);
  }
});

export default router;
