import { MongoClient } from "mongodb";

const client = new MongoClient("mongodb://localhost:27017");
await client.connect();
const db = client.db("cyber-police");
const col = db.collection("users");

const user = await col.findOne({ email: "admin@cybershield.gov.in" });
console.log("User found:", !!user);
console.log("Current role:", user?.role);
console.log("Current fullName:", user?.fullName);

// Update user with required fields
await col.updateOne(
  { email: "admin@cybershield.gov.in" },
  { 
    $set: { 
      role: "police",
      fullName: "Admin Officer",
      status: "active"
    } 
  }
);

const updated = await col.findOne({ email: "admin@cybershield.gov.in" });
console.log("Updated role:", updated?.role);
console.log("Updated fullName:", updated?.fullName);
console.log("Has password:", !!updated?.passwordHash);
console.log("Done!");

await client.close();