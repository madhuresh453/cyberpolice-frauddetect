import { MongoClient } from "mongodb";

const client = new MongoClient("mongodb://localhost:27017");
await client.connect();
const db = client.db("cyber-police");
const col = db.collection("users");

// Check all users
const allUsers = await col.find({}).toArray();
for (const u of allUsers) {
  const changes = {};
  // Remove incompatible roles field
  if (u.roles) {
    changes.$unset = { roles: "" };
  }
  // Ensure required fields exist
  if (!u.role) changes.role = "citizen";
  if (!u.fullName) changes.fullName = u.email || "Unknown";
  if (!u.status) changes.status = "active";
  
  if (Object.keys(changes).length > 0 || changes.$unset) {
    const update = {};
    if (!changes.$unset) {
      for (const [k, v] of Object.entries(changes)) {
        update[k] = v;
      }
      await col.updateOne({ _id: u._id }, { $set: update });
    } else {
      await col.updateOne({ _id: u._id }, changes);
    }
    console.log(`Fixed user: ${u.email} (removed roles: ${!!u.roles}, added role: ${u.role || "citizen"})`);
  } else {
    console.log(`User ${u.email} OK`);
  }
}

console.log("Done!");
await client.close();