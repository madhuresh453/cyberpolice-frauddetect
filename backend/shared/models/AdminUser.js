import { createModel, objectId } from "./base.js";

export default createModel(
  "AdminUser",
  {
    userId: { type: objectId, ref: "User", required: true, unique: true, index: true },
    department: { type: String, required: true, trim: true },
    designation: { type: String, required: true, trim: true },
    privileges: { type: [String], default: [], index: true }
  },
  { collection: "admin_users", indexes: [{ fields: { department: 1, designation: 1 } }] }
);
