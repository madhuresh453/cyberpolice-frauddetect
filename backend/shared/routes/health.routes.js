import { Router } from "express";
import mongoose from "mongoose";
import { getDatabaseHealth } from "../database/healthcheck.js";

const router = Router();

router.get("/api/v1/health", async (_req, res) => {
  const health = await getDatabaseHealth();
  res.status(health.connected ? 200 : 503).json({
    status: health.connected ? "healthy" : "unhealthy",
    database: health.connected ? "connected" : "disconnected",
    timestamp: new Date().toISOString(),
  });
});

export default router;