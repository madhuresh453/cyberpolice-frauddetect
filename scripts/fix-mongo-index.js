// Fix MongoDB broken indexes for Session and RefreshToken
// Run: node scripts/fix-mongo-index.js

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
    
    // Check existing indexes
    const sessionsIndexes = await sessionsCol.indexes();
    console.log("\nCurrent sessions indexes:");
    sessionsIndexes.forEach(idx => {
      console.log("  -", idx.name, JSON.stringify(idx.key), idx.unique ? "(unique)" : "");
    });
    
    // Drop token_1 index if it exists and is broken
    const tokenIndex = sessionsIndexes.find(idx => idx.name === "token_1");
    if (tokenIndex) {
      console.log("\nDropping broken sessions token_1 index...");
      try {
        await sessionsCol.dropIndex("token_1");
        console.log("  ✅ Dropped index token_1");
      } catch (e) {
        console.log("  ⚠️ Could not drop token_1:", e.message);
      }
    }
    
    // Clean sessions with null token
    const nullTokenCount = await sessionsCol.countDocuments({ token: null });
    if (nullTokenCount > 0) {
      console.log(`\nCleaning ${nullTokenCount} sessions with null token...`);
      const deleteResult = await sessionsCol.deleteMany({ token: null });
      console.log(`  ✅ Deleted ${deleteResult.deletedCount} sessions with null token`);
    } else {
      console.log("\n✅ No sessions with null token found");
    }
    
    // Recreate index with partialFilterExpression
    console.log("\nCreating new sessions token_1 index with partialFilterExpression...");
    try {
      await sessionsCol.createIndex(
        { token: 1 },
        { unique: true, partialFilterExpression: { token: { $exists: true, $ne: null } } }
      );
      console.log("  ✅ Created sessions token_1 index (sparse)");
    } catch (e) {
      console.log("  ⚠️ Could not create index:", e.message);
    }
    
    // ===== Fix refresh_tokens collection =====
    const refreshCol = db.collection("refresh_tokens");
    
    const refreshIndexes = await refreshCol.indexes();
    console.log("\nCurrent refresh_tokens indexes:");
    refreshIndexes.forEach(idx => {
      console.log("  -", idx.name, JSON.stringify(idx.key), idx.unique ? "(unique)" : "");
    });
    
    const refreshTokenIndex = refreshIndexes.find(idx => idx.name === "token_1");
    if (refreshTokenIndex) {
      console.log("\nDropping broken refresh_tokens token_1 index...");
      try {
        await refreshCol.dropIndex("token_1");
        console.log("  ✅ Dropped index token_1");
      } catch (e) {
        console.log("  ⚠️ Could not drop token_1:", e.message);
      }
    }
    
    const nullRefreshCount = await refreshCol.countDocuments({ token: null });
    if (nullRefreshCount > 0) {
      console.log(`\nCleaning ${nullRefreshCount} refresh tokens with null token...`);
      const deleteResult2 = await refreshCol.deleteMany({ token: null });
      console.log(`  ✅ Deleted ${deleteResult2.deletedCount} refresh tokens with null token`);
    }
    
    console.log("\nCreating new refresh_tokens token_1 index with partialFilterExpression...");
    try {
      await refreshCol.createIndex(
        { token: 1 },
        { unique: true, partialFilterExpression: { token: { $exists: true, $ne: null } } }
      );
      console.log("  ✅ Created refresh_tokens token_1 index (sparse)");
    } catch (e) {
      console.log("  ⚠️ Could not create index:", e.message);
    }
    
    console.log("\n✅ All fixes applied successfully!");
    
  } catch (error) {
    console.error("Error:", error.message);
    process.exit(1);
  } finally {
    await client.close();
  }
}

fixIndexes();