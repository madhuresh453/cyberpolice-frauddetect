import { MongoClient } from "mongodb";

const c = new MongoClient("mongodb://localhost:27017");
await c.connect();
const db = c.db("cyber-police");
const col = db.collection("users");
await col.updateMany({}, { $unset: { roles: "" } });
console.log("Removed roles field from all users");
const admin = await col.findOne({email:"admin@cybershield.gov.in"});
console.log("admin roles:", admin.roles);
console.log("admin role:", admin.role);
await c.close();