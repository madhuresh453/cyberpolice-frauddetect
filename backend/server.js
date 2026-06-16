import { createServer } from "node:http";
import { config } from "./shared/database/database.config.js";
import { connectMongoDB, disconnectMongoDB } from "./shared/database/mongodb.js";
import { verifyCollections, verifyIndexes } from "./shared/services/mongodb.service.js";
import { createApp } from "./app.js";

let io;
export function getSocketIO() { return io; }

async function startServer() {
  await connectMongoDB();
  await verifyIndexes();
  await verifyCollections();

  const app = createApp();
  const server = createServer(app);

  // ===== WebSocket (Socket.IO) for real-time citizen ↔ police sync =====
  try {
    const { Server: SocketIOServer } = await import("socket.io");
    io = new SocketIOServer(server, {
      cors: { origin: "*", methods: ["GET", "POST"] },
      path: "/ws",
      transports: ["websocket", "polling"],
    });

    io.on("connection", (socket) => {
      console.log(`[WS] Client connected: ${socket.id}`);

      // Police dashboard joins the "police" room
      socket.on("join:police", () => {
        socket.join("police");
        console.log(`[WS] ${socket.id} joined police room`);
      });

      // Citizen app joins its user-specific room
      socket.on("join:citizen", (userId) => {
        socket.join(`citizen:${userId}`);
        console.log(`[WS] ${socket.id} joined citizen room: ${userId}`);
      });

      // New fraud case submitted by citizen
      socket.on("fraud:report", (data) => {
        // Broadcast to all police dashboards instantly
        io.to("police").emit("fraud:new", {
          ...data,
          timestamp: new Date().toISOString(),
          socketId: socket.id,
        });
        console.log(`[WS] Fraud report broadcast to police: ${data.type || "unknown"}`);
      });

      // AI analysis complete — push to police
      socket.on("analysis:complete", (data) => {
        io.to("police").emit("analysis:new", data);
      });

      // Emergency SOS
      socket.on("sos:triggered", (data) => {
        io.to("police").emit("sos:incoming", {
          ...data,
          timestamp: new Date().toISOString(),
        });
      });

      // Police updates case status — push to citizen
      socket.on("case:update", (data) => {
        const citizenRoom = `citizen:${data.userId}`;
        io.to(citizenRoom).emit("case:status", data);
        io.to("police").emit("case:updated", data);
      });

      socket.on("disconnect", () => {
        console.log(`[WS] Client disconnected: ${socket.id}`);
      });
    });

    console.log("[WS] Socket.IO WebSocket server initialized on /ws");
  } catch (wsErr) {
    console.warn("[WS] Socket.IO not available (install socket.io to enable):", wsErr.message);
  }

  server.on("error", async (error) => {
    if (error.code === "EADDRINUSE") {
      console.error(
        JSON.stringify({
          level: "fatal",
          message: `Port ${config.port} is already in use`,
          port: config.port,
          error: "EADDRINUSE"
        })
      );
      await disconnectMongoDB();
      process.exit(1);
    } else {
      throw error;
    }
  });

  server.listen(config.port, () => {
    console.log(
      JSON.stringify({
        level: "info",
        message: "CyberShield-AI backend started",
        port: config.port,
        database: config.dbName,
        environment: config.nodeEnv
      })
    );
  });

  const shutdown = async (signal) => {
    console.log(JSON.stringify({ level: "info", message: "Shutdown requested", signal }));
    server.close(async () => {
      await disconnectMongoDB();
      process.exit(0);
    });
  };

  process.on("SIGINT", shutdown);
  process.on("SIGTERM", shutdown);
}

startServer().catch(async (error) => {
  console.error(
    JSON.stringify({
      level: "fatal",
      message: "Failed to start CyberShield-AI backend",
      error: error.message
    })
  );
  await disconnectMongoDB();
  process.exit(1);
});