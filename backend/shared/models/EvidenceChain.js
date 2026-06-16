import mongoose from "mongoose";

const evidenceChainSchema = new mongoose.Schema({
  evidenceId: { type: String, required: true, index: true },
  sessionId: { type: String, required: true, index: true },
  caseId: { type: String, default: "" },
  type: { type: String, required: true },
  source: { type: String, default: "" },
  destination: { type: String, default: "" },
  status: { type: String, default: "" },
  riskScore: { type: Number, default: 0 },
  riskLevel: { type: String, default: "NONE" },
  hash: { type: String, required: true },
  previousHash: { type: String, default: "" },
  blockHash: { type: String, default: "" },
  messageHash: { type: String, default: "" },
  officerId: { type: String, default: "" },
  transferReason: { type: String, default: "" }
}, {
  collection: "evidence_chains",
  timestamps: true
});

evidenceChainSchema.index({ sessionId: 1, createdAt: 1 });
evidenceChainSchema.index({ evidenceId: 1 });
evidenceChainSchema.index({ caseId: 1 });
evidenceChainSchema.index({ type: 1 });
evidenceChainSchema.index({ hash: 1 });

const EvidenceChain = mongoose.model("EvidenceChain", evidenceChainSchema);
export default EvidenceChain;