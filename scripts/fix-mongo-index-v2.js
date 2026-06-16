import { MongoClient } from "mongodb";

const MONGO_URL = process.env.MONGO_URL || "mongodb://localhost:27017";
const DB_NAME = process.env.DB_NAME || "cyber-police";

async function fixIndexes() {
  const client = new MongoClient(MONGO_URL);
  
  try {
    await client.connect();
    const db = client.db(DB_NAME);
    
    console.log("Connected to MongoDB:", DB_NAME);
    
    // ===== Fix sessions collection =====
    const sessionsCol = db.collection("sessions");
    
    // Clean sessions with null token
    const nullTokenCount = await sessionsCol.countDocuments({ token: null });
    if (nullTokenCount > 0) {
      console.log(`Cleaning ${nullTokenCount} sessions with null token...`);
      await sessionsCol.deleteMany({ token: null });
      console.log("  ✅ Cleaned");
    } else {
      console.log("✅ No sessions with null token");
    }
    
    // Create correct index with $type: "string"
    console.log("Creating sessions token_1 index...");
    try {
      await sessionsCol.createIndex(
        { token: 1 },
        { 
          unique: true, 
          partialFilterExpression: { token: { $type: "string" } },
          name: "token_1"
        }
      );
      console.log("  ✅ sessions token_1 index created");
    } catch (e) {
      console.log("  ⚠️ Error:", e.message);
      // If still fails, try dropping and recreating
      try {
        await sessionsCol.dropIndex("token_1");
        await sessionsCol.createIndex(
          { token: 1 },
          { 
            unique: true, 
            partialFilterExpression: { token: { $type: "string" } },
            name: "token_1"
          }
        );
        console.log("  ✅ Recreated after drop");
      } catch (e2) {
        console.log("  ⚠️ Could not recreate:", e2.message);
      }
    }
    
    // ===== Fix refresh_tokens collection =====
    const refreshCol = db.collection("refresh_tokens");
    
    // Clean refresh tokens with null token
    const nullRefreshCount = await refreshCol.countDocuments({ token: null });
    if (nullRefreshCount > 0) {
      console.log(`\nCleaning ${nullRefreshCount} refresh tokens with null token...`);
      await refreshCol.deleteMany({ token: null });
      console.log("  ✅ Cleaned");
    } else {
      console.log("\n✅ No refresh tokens with null token");
    }
    
    // The refresh_tokens already has token_1 dropped, now recreate
    console.log("Creating refresh_tokens token_1 index...");
    try {
      await refreshCol.createIndex(
        { token: 1 },
        { 
          unique: true, 
          partialFilterExpression: { token: { $type: "string" } },
          name: "token_1"
        }
      );
      console.log("  ✅ refresh_tokens token_1 index created");
    } catch (e) {
      console.log("  ⚠️ Error:", e.message);
    }
    
    // Verify final state
    console.log("\n=== Final Index State ===");
    const sessIdx = await sessionsCol.indexes();
    sessIdx.forEach(i => console.log(`sessions: ${i.name} ${JSON.stringify(i.key)} ${i.unique ? "(unique)" : ""}`));
    
    const refIdx = await refreshCol.indexes();
    refIdx.forEach(i => console.log(`refresh_tokens: ${i.name} ${JSON.stringify(i.key)} ${i.unique ? "(unique)" : ""}`));
    
    console.log("\n✅ All fixes applied!");
    
  } catch (error) {
    console.error("Error:", error.message);
    process.exit(1);
  } finally {
    await client.close();
  }
}

fixIndexes();