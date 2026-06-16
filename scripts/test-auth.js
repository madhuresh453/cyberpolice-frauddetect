import { MongoClient } from "mongodb";

const MONGO_URL = process.env.MONGO_URL || "mongodb://localhost:27017";
const DB_NAME = process.env.DB_NAME || "cyber-police";
const API = "http://localhost:5000/api/v1";

async function main() {
  const client = new MongoClient(MONGO_URL);
  
  try {
    await client.connect();
    const db = client.db(DB_NAME);
    const usersCol = db.collection("users");
    
    // Check existing user
    const user = await usersCol.findOne({ email: "admin@cybershield.gov.in" });
    
    if (user) {
      console.log("User exists:", user.email);
      if (user.passwordHash) {
        console.log("Password hash exists:", user.passwordHash.substring(0, 20) + "...");
      } else {
        console.log("No password hash! Adding one...");
        const bcrypt = await import("bcryptjs");
        const hash = bcrypt.hashSync("CyberShield@2026", 12);
        await usersCol.updateOne(
          { email: "admin@cybershield.gov.in" },
          { $set: { passwordHash: hash } }
        );
        console.log("Added password hash");
      }
    } else {
      console.log("No user found. Creating new one...");
      const bcrypt = await import("bcryptjs");
      const hash = bcrypt.hashSync("CyberShield@2026", 12);
      await usersCol.insertOne({
        email: "admin@cybershield.gov.in",
        phoneNumber: "+919876543210",
        passwordHash: hash,
        fullName: "Admin Officer",
        role: "police",
        status: "active",
        createdAt: new Date(),
        updatedAt: new Date(),
      });
      console.log("User created");
    }
    
    console.log("\n=== Testing Login ===");
    try {
      const resp = await fetch(`${API}/auth/login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email: "admin@cybershield.gov.in", password: "CyberShield@2026" }),
      });
      const data = await resp.json();
      console.log("Status:", resp.status);
      if (resp.ok) {
        console.log("Login SUCCESS!");
        console.log("Access token:", data.access_token ? data.access_token.substring(0, 40) + "..." : "N/A");
        console.log("User:", JSON.stringify(data.user, null, 2));
      } else {
        console.log("Login FAILED:", JSON.stringify(data));
      }
    } catch (e) {
      console.log("Login error:", e.message);
    }
    
    console.log("\nDone!");
    
  } catch (error) {
    console.error("Error:", error.message);
    process.exit(1);
  } finally {
    await client.close();
  }
}

main();