import { AuditLog } from "../models/index.js";

export class AuditLogService {
  async record({
    actorUserId = null,
    actorRole = "system",
    action,
    resource,
    resourceId = null,
    before = null,
    after = null,
    ipAddress = null,
    userAgent = null,
    requestId = null
  }) {
    return AuditLog.create({
      actorUserId,
      actorRole,
      action,
      resource,
      resourceId,
      before,
      after,
      ipAddress,
      userAgent,
      requestId,
      createdByRole: actorRole,
      accessRoles: ["admin", "police"]
    });
  }
}

export const auditLogService = new AuditLogService();
