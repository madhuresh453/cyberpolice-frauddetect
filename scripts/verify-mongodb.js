import { connectMongoDB, disconnectMongoDB } from "../backend/shared/database/mongodb.js";
import { getDatabaseHealth } from "../backend/shared/database/healthcheck.js";
import { models } from "../backend/shared/models/index.js";
import { verifyCollections, verifyIndexes } from "../backend/shared/services/mongodb.service.js";

async function verify() {
  await connectMongoDB();
  await verifyIndexes();
  await verifyCollections();

  const health = await getDatabaseHealth();
  const expectedCollections = Object.values(models).map((model) => model.collection.name).sort();
  const missing = expectedCollections.filter((name) => !health.collections.includes(name));

  if (!health.connected) {
    throw new Error("MongoDB is not connected");
  }

  if (missing.length > 0) {
    throw new Error(`Missing collections: ${missing.join(", ")}`);
  }

  console.log(
    JSON.stringify(
      {
        status: "ok",
        database: health.database,
        connected: health.connected,
        collections: health.collections
      },
      null,
      2
    )
  );
}

verify()
  .catch((error) => {
    console.error(JSON.stringify({ status: "failed", error: error.message }, null, 2));
    process.exitCode = 1;
  })
  .finally(async () => {
    await disconnectMongoDB();
  });
