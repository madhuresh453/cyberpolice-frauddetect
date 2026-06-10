import dotenv from "dotenv";

dotenv.config();

const required = ["MONGODB_URI", "DB_NAME", "JWT_SECRET"];

for (const key of required) {
  if (!process.env[key]) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
}

if (process.env.DB_NAME !== "cyber-police") {
  throw new Error("DB_NAME must be exactly cyber-police");
}

export const config = Object.freeze({
  mongodbUri: process.env.MONGODB_URI,
  dbName: process.env.DB_NAME,
  port: Number.parseInt(process.env.PORT || "5000", 10),
  jwtSecret: process.env.JWT_SECRET,
  nodeEnv: process.env.NODE_ENV || "development",
  mongo: {
    maxPoolSize: Number.parseInt(process.env.MONGO_MAX_POOL_SIZE || "50", 10),
    minPoolSize: Number.parseInt(process.env.MONGO_MIN_POOL_SIZE || "5", 10),
    serverSelectionTimeoutMS: Number.parseInt(
      process.env.MONGO_SERVER_SELECTION_TIMEOUT_MS || "10000",
      10
    ),
    socketTimeoutMS: Number.parseInt(process.env.MONGO_SOCKET_TIMEOUT_MS || "45000", 10),
    connectTimeoutMS: Number.parseInt(process.env.MONGO_CONNECT_TIMEOUT_MS || "10000", 10),
    heartbeatFrequencyMS: Number.parseInt(process.env.MONGO_HEARTBEAT_MS || "10000", 10)
  }
});
