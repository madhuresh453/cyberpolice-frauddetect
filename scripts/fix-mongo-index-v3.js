import { MongoClient } from "mongodb";

const MONGO_URL = process.env.MONGO_URL || "mongodb://localhost:27017";
const DB_NAME = process.env.DB_NAME || "cyber-police";

async function fixIndexes() {
  const client = new MongoClient(MONGO_URL);
  try {
    await client.connect();
    const db = client.db(DB_NAME);
    console.log("Connected to MongoDB:", DB_NAME);
    
    // ===== Fix sessions =====
    const sessionsCol = db.collection("sessions");
    let sessIdx = await sessionsCol.indexes();
    console.log("\nBefore sessions indexes:", sessIdx.map(i => i.name));
    
    // Drop ALL token_1 indexes first
    for (const idx of sessIdx) {
      if (idx.name === "token_1") {
        console.log(`Dropping sessions index: ${idx.name} (unique=${!!idx.unique})`);
        await sessionsCol.dropIndex(idx.name);
      }
    }
    
    // Clean null tokens
    const nullCount = await sessionsCol.countDocuments({ token: null });
    if (nullCount > 0) {
      await sessionsCol.deleteMany({ token: null });
      console.log(`Deleted ${nullCount} sessions with null token`);
    }
    
    // Recreate token_1 with partialFilterExpression
    await sessionsCol.createIndex(
      { token: 1 },
      { unique: true, partialFilterExpression: { token: { $type: "string" } }, name: "token_1" }
    );
    console.log("✅ sessions token_1 created (partialFilterExpression)");
    
    // ===== Fix refresh_tokens =====
    const refCol = db.collection("refresh_tokens");
    let refIdx = await refCol.indexes();
    console.log("\nBefore refresh_tokens indexes:", refIdx.map(i => i.name));
    
    for (const idx of refIdx) {
      if (idx.name === "token_1") {
        console.log(`Dropping refresh_tokens index: ${idx.name}`);
        await refCol.dropIndex(idx.name);
      }
    }
    
    await refCol.createIndex(
      { token: 1 },
      { unique: true, partialFilterExpression: { token: { $type: "string" } }, name: "token_1" }
    );
    console.log("✅ refresh_tokens token_1 created (partialFilterExpression)");
    
    // Verify
    sessIdx = await sessionsCol.indexes();
    console.log("\nFinal sessions token_1:", sessIdx.find(i => i.name === "token_1"));
    refIdx = await refCol.indexes();
    console.log("Final refresh_tokens token_1:", refIdx.find(i => i.name === "token_1"));
    
    console.log("\n✅ All fixed!");
  } catch (e) {
    console.error("Error:", e.message);
    process.exit(1);
  } finally {
    await client.close();
  }
}

fixIndexes();