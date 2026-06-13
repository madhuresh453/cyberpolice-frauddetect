import mongoose from "mongoose";
import { normalizePhoneToE164 } from "../utils/phone.utils.js";

const userSchema = new mongoose.Schema(
  {
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
      index: true,
    },
    phoneNumber: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true,
    },
    passwordHash: {
      type: String,
      required: true,
      select: false,
    },
    fullName: {
      type: String,
      required: true,
      trim: true,
    },
    role: {
      type: String,
      enum: ["citizen", "police", "isp", "admin", "super_admin"],
      default: "citizen",
    },
    status: {
      type: String,
      enum: ["active", "inactive", "suspended", "banned"],
      default: "active",
    },
    googleId: {
      type: String,
      index: true,
      sparse: true,
    },
    lastLoginAt: {
      type: Date,
    },
  },
  {
    timestamps: true,
    collection: "users",
  }
);

// Normalize phone number to E.164 before saving
userSchema.pre("save", function (next) {
  if (this.isModified("phoneNumber")) {
    this.phoneNumber = normalizePhoneToE164(this.phoneNumber);
  }
  next();
});

// Support querying by phone_number (snake_case) transparently
userSchema.virtual("phone_number").get(function () {
  return this.phoneNumber;
});

userSchema.set("toJSON", {
  virtuals: true,
  transform: (_doc, ret) => {
    ret.id = ret._id.toString();
    ret.phone_number = ret.phoneNumber;
    delete ret.passwordHash;
    delete ret.__v;
    delete ret._id;
    return ret;
  },
});

export const User = mongoose.models.User || mongoose.model("User", userSchema);