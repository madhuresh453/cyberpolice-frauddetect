import mongoose from "mongoose";
import { config } from "../database/database.config.js";
import { getDatabaseHealth } from "../database/healthcheck.js";
import { models } from "../models/index.js";

export class MongoDBService {
  async status() {
    return getDatabaseHealth();
  }

  async verifyIndexes() {
    const results = {};
    for (const [name, model] of Object.entries(models)) {
      results[name] = await model.syncIndexes();
    }
    return results;
  }

  async verifyCollections() {
    const existingCollections = await mongoose.connection.db.listCollections().toArray();
    const existingNames = new Set(existingCollections.map((collection) => collection.name));

    for (const model of Object.values(models)) {
      if (!existingNames.has(model.collection.name)) {
        await model.createCollection();
      }
    }

    return mongoose.connection.db.listCollections().toArray();
  }

  async connectionSummary() {
    const health = await this.status();
    return {
      database: config.dbName,
      collections: health.collections,
      connected: health.connected
    };
  }
}

export const mongoDBService = new MongoDBService();

export async function verifyIndexes() {
  return mongoDBService.verifyIndexes();
}

export async function verifyCollections() {
  return mongoDBService.verifyCollections();
}
