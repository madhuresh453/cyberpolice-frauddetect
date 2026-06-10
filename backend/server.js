import { createServer } from "node:http";
import { config } from "./shared/database/database.config.js";
import { connectMongoDB, disconnectMongoDB } from "./shared/database/mongodb.js";
import { verifyCollections, verifyIndexes } from "./shared/services/mongodb.service.js";
import { createApp } from "./app.js";

async function startServer() {
  await connectMongoDB();
  await verifyIndexes();
  await verifyCollections();

  const app = createApp();
  const server = createServer(app);

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