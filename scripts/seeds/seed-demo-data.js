import crypto from "node:crypto";
import { connectMongoDB, disconnectMongoDB } from "../../backend/shared/database/mongodb.js";
import {
  AIPrediction,
  AdminUser,
  Call,
  Citizen,
  Complaint,
  FIRReport,
  PoliceOfficer,
  ScamAlert,
  User
} from "../../backend/shared/models/index.js";
import { transactionService } from "../../backend/shared/services/transaction.service.js";
import { verifyCollections, verifyIndexes } from "../../backend/shared/services/mongodb.service.js";

function hashPassword(value) {
  return crypto.createHash("sha256").update(value).digest("hex");
}

async function upsertUser({ email, phoneNumber, fullName, role }) {
  return User.findOneAndUpdate(
    { email },
    {
      email,
      phoneNumber,
      fullName,
      role,
      roles: [role],
      passwordHash: hashPassword("CyberShield@2026"),
      status: "active",
      createdByRole: "system",
      accessRoles: ["admin"]
    },
    { upsert: true, new: true, runValidators: true, setDefaultsOnInsert: true }
  );
}

async function seed() {
  await connectMongoDB();
  await verifyIndexes();
  await verifyCollections();

  await transactionService.run(async (session) => {
    const adminUser = await upsertUser({
      email: "admin@cybershield.gov.in",
      phoneNumber: "+911140000001",
      fullName: "CyberShield Admin",
      role: "admin"
    });

    const policeUser = await upsertUser({
      email: "inspector.gurugram@cybershield.gov.in",
      phoneNumber: "+911240000001",
      fullName: "Inspector Asha Verma",
      role: "police"
    });

    const citizenUser = await upsertUser({
      email: "citizen.demo@example.com",
      phoneNumber: "+919812345678",
      fullName: "Demo Citizen",
      role: "citizen"
    });

    const [admin, officer, citizen] = await Promise.all([
      AdminUser.findOneAndUpdate(
        { userId: adminUser._id },
        {
          userId: adminUser._id,
          department: "CyberShield Operations",
          designation: "Platform Administrator",
          privileges: ["users:manage", "database:monitor", "audit:read"],
          createdByRole: "system",
          accessRoles: ["admin"]
        },
        { upsert: true, new: true, runValidators: true, session }
      ),
      PoliceOfficer.findOneAndUpdate(
        { userId: policeUser._id },
        {
          userId: policeUser._id,
          badgeNumber: "GGM-CYBER-001",
          rank: "Inspector",
          stationName: "Gurugram Cyber Police Station",
          state: "Haryana",
          district: "Gurugram",
          contactNumber: "+911240000001",
          permissions: ["cases:read", "cases:write", "fir:create"],
          createdByRole: "admin",
          accessRoles: ["admin", "police"]
        },
        { upsert: true, new: true, runValidators: true, session }
      ),
      Citizen.findOneAndUpdate(
        { userId: citizenUser._id },
        {
          userId: citizenUser._id,
          phoneNumber: "+919812345678",
          preferredLanguage: "en",
          state: "Haryana",
          district: "Gurugram",
          consent: { version: "2026.1", acceptedAt: new Date() },
          createdByRole: "citizen",
          accessRoles: ["citizen", "police", "admin"]
        },
        { upsert: true, new: true, runValidators: true, session }
      )
    ]);

    const complaint = await Complaint.findOneAndUpdate(
      { complaintNumber: "CMP-DEMO-0001" },
      {
        complaintNumber: "CMP-DEMO-0001",
        citizenId: citizen._id,
        assignedOfficerId: officer._id,
        scamType: "otp_fraud",
        riskLevel: "high",
        accusedNumber: "+919876543210",
        amountLostPaise: 0,
        description: "Demo HDFC OTP scam attempt detected and reported by CyberShield AI.",
        status: "investigating",
        createdByRole: "citizen",
        accessRoles: ["citizen", "police", "admin"]
      },
      { upsert: true, new: true, runValidators: true, session }
    );

    const call = await Call.findOneAndUpdate(
      { citizenId: citizen._id, callerNumber: "+919876543210" },
      {
        citizenId: citizen._id,
        callerNumber: "+919876543210",
        receiverNumber: citizen.phoneNumber,
        direction: "incoming",
        startedAt: new Date(),
        durationSeconds: 48,
        riskLevel: "high",
        status: "blocked",
        createdByRole: "citizen",
        accessRoles: ["citizen", "police", "admin"]
      },
      { upsert: true, new: true, runValidators: true, session }
    );

    await Promise.all([
      FIRReport.findOneAndUpdate(
        { firNumber: "FIR-GGM-DEMO-0001" },
        {
          firNumber: "FIR-GGM-DEMO-0001",
          complaintId: complaint._id,
          citizenId: citizen._id,
          officerId: officer._id,
          accusedNumber: "+919876543210",
          policeStation: "Gurugram Cyber Police Station",
          sections: ["IT Act 66D", "IPC 420"],
          narrative: "Attempted bank impersonation and OTP harvesting call blocked by CyberShield AI.",
          filedAt: new Date(),
          createdByRole: "police",
          accessRoles: ["police", "admin"]
        },
        { upsert: true, new: true, runValidators: true, session }
      ),
      ScamAlert.findOneAndUpdate(
        { callId: call._id, citizenId: citizen._id },
        {
          callId: call._id,
          citizenId: citizen._id,
          phoneNumber: "+919876543210",
          alertType: "otp_fraud",
          riskLevel: "high",
          riskScore: 91,
          message: "High-risk OTP fraud detected from unknown caller.",
          createdByRole: "system",
          accessRoles: ["citizen", "police", "admin"]
        },
        { upsert: true, new: true, runValidators: true, session }
      ),
      AIPrediction.findOneAndUpdate(
        { entityType: "call", entityId: call._id },
        {
          entityType: "call",
          entityId: call._id,
          modelName: "cybershield-scam-classifier",
          modelVersion: "2026.1.0",
          riskLevel: "high",
          riskScore: 91,
          confidence: 96,
          features: { keywords: "hdfc,otp,blocked,verify", language: "en" },
          explanation: "Detected bank impersonation and OTP request pattern.",
          createdByRole: "system",
          accessRoles: ["police", "admin"]
        },
        { upsert: true, new: true, runValidators: true, session }
      )
    ]);

    console.log(
      JSON.stringify({
        level: "info",
        message: "Demo seed data upserted",
        adminUserId: admin.userId.toString(),
        officerId: officer._id.toString(),
        citizenId: citizen._id.toString()
      })
    );
  });
}

seed()
  .catch((error) => {
    console.error(JSON.stringify({ level: "error", message: "Seed failed", error: error.message }));
    process.exitCode = 1;
  })
  .finally(async () => {
    await disconnectMongoDB();
  });
