import mongoose from "mongoose";
import { config } from "./database.config.js";

let isConfigured = false;

function configureMongoose() {
  if (isConfigured) return;

  mongoose.set("strictQuery", true);
  mongoose.set("sanitizeFilter", true);

  mongoose.connection.on("connected", () => {
    console.log(JSON.stringify({ level: "info", message: "MongoDB connected" }));
  });

  mongoose.connection.on("reconnected", () => {
    console.log(JSON.stringify({ level: "info", message: "MongoDB reconnected" }));
  });

  mongoose.connection.on("disconnected", () => {
    console.warn(JSON.stringify({ level: "warn", message: "MongoDB disconnected" }));
  });

  mongoose.connection.on("error", (error) => {
    console.error(
      JSON.stringify({ level: "error", message: "MongoDB connection error", error: error.message })
    );
  });

  isConfigured = true;
}

export async function connectMongoDB() {
  configureMongoose();

  if (mongoose.connection.readyState === 1) {
    return mongoose.connection;
  }

  await mongoose.connect(config.mongodbUri, {
    dbName: config.dbName,
    autoIndex: true,
    maxPoolSize: config.mongo.maxPoolSize,
    minPoolSize: config.mongo.minPoolSize,
    serverSelectionTimeoutMS: config.mongo.serverSelectionTimeoutMS,
    socketTimeoutMS: config.mongo.socketTimeoutMS,
    connectTimeoutMS: config.mongo.connectTimeoutMS,
    heartbeatFrequencyMS: config.mongo.heartbeatFrequencyMS
  });

  return mongoose.connection;
}

export async function disconnectMongoDB() {
  if (mongoose.connection.readyState !== 0) {
    await mongoose.disconnect();
  }
}

export function getMongoConnection() {
  return mongoose.connection;
}
