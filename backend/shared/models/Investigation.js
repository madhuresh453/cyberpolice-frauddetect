import { createModel, objectId } from "./base.js";

export default createModel(
  "Investigation",
  {
    caseId: { type: objectId, ref: "Case", required: true, index: true },
    firId: { type: objectId, ref: "FIR", index: true },
    officerId: { type: objectId, ref: "PoliceOfficer", required: true, index: true },
    status: { type: String, enum: ["assigned", "in_progress", "evidence_collection", "analysis", "report_pending", "completed", "closed"], default: "assigned", index: true },
    priority: { type: String, enum: ["low", "medium", "high", "critical"], default: "medium" },
    findings: [{ type: String }],
    evidenceCollected: [{ type: objectId, ref: "EvidenceFile" }],
    witnesses: [{ name: String, phone: String, statement: String, dateCollected: Date }],
    suspectDetails: [{ name: String, phone: String, address: String, role: String, riskScore: Number }],
    timeline: [{
      action: String,
      performedBy: { type: objectId, ref: "PoliceOfficer" },
      timestamp: { type: Date, default: Date.now },
      details: String,
      status: String
    }],
    assignedAt: { type: Date, default: Date.now },
    startedAt: { type: Date },
    completedAt: { type: Date },
    deadline: { type: Date },
    notes: { type: String, maxlength: 2000 },
    relatedInvestigations: [{ type: objectId, ref: "Investigation" }]
  },
  {
    collection: "investigations",
    indexes: [
      { fields: { caseId: 1, status: 1 } },
      { fields: { officerId: 1, status: 1 } },
      { fields: { status: 1, priority: 1 } },
      { fields: { assignedAt: -1 } },
      { fields: { deadline: 1, status: 1 } }
    ]
  }
);