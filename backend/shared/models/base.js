import mongoose from "mongoose";

export const ROLES = ["citizen", "police", "admin", "isp", "system"];
export const RISK_LEVELS = ["safe", "low", "medium", "high", "critical"];
export const STATUS_VALUES = ["active", "inactive", "suspended", "deleted"];

export const objectId = mongoose.Schema.Types.ObjectId;

export function applyBaseSchemaOptions(schema) {
  schema.add({
    deletedAt: { type: Date, default: null, index: true },
    deletedBy: { type: objectId, ref: "User", default: null },
    createdBy: { type: objectId, ref: "User", default: null },
    createdByRole: { type: String, enum: ROLES, default: "system", index: true },
    accessRoles: { type: [String], enum: ROLES, default: ["admin"], index: true }
  });

  schema.set("timestamps", true);
  schema.set("toJSON", {
    virtuals: true,
    versionKey: false,
    transform: (_doc, ret) => {
      ret.id = ret._id.toString();
      delete ret._id;
      return ret;
    }
  });

  schema.pre(/^find/, function excludeSoftDeleted(next) {
    if (!this.getOptions().withDeleted) {
      this.where({ deletedAt: null });
    }
    next();
  });

  schema.index({ createdAt: -1 });
  schema.index({ updatedAt: -1 });
  schema.index({ deletedAt: 1, createdAt: -1 });
}

export function createModel(name, schemaDefinition, options = {}) {
  const schema = new mongoose.Schema(schemaDefinition, {
    collection: options.collection,
    timestamps: true,
    strict: "throw"
  });

  applyBaseSchemaOptions(schema);

  if (options.indexes) {
    for (const index of options.indexes) {
      schema.index(index.fields, index.options || {});
    }
  }

  return mongoose.models[name] || mongoose.model(name, schema);
}

export const phoneValidator = {
  validator: (value) => !value || /^\+[1-9]\d{7,14}$/.test(value),
  message: "Phone number must be in E.164 format"
};

export const upiValidator = {
  validator: (value) => !value || /^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$/.test(value),
  message: "UPI ID is invalid"
};
