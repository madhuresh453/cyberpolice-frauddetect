import mongoose from "mongoose";
import { config } from "./database.config.js";

export async function getDatabaseHealth() {
  const connected = mongoose.connection.readyState === 1;
  const payload = {
    database: config.dbName,
    connected,
    readyState: mongoose.connection.readyState,
    host: mongoose.connection.host || null,
    collections: []
  };

  if (!connected || !mongoose.connection.db) {
    return payload;
  }

  const admin = mongoose.connection.db.admin();
  const ping = await admin.ping();
  const collections = await mongoose.connection.db.listCollections().toArray();

  return {
    ...payload,
    pingOk: ping.ok === 1,
    collections: collections.map((collection) => collection.name).sort()
  };
}
