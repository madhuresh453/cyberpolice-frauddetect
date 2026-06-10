const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";

async function fetchAPI<T>(endpoint: string, options?: RequestInit): Promise<T> {
  const token = typeof window !== "undefined" ? localStorage.getItem("cybershield_token") : null;
  const res = await fetch(`${API_BASE}${endpoint}`, {
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...options?.headers,
    },
    ...options,
  });
  if (!res.ok) throw new Error(`API Error: ${res.status} ${res.statusText}`);
  return res.json();
}

// Dashboard
export const getDashboardStats = () => fetchAPI<any>("/api/v1/analytics/dashboard");
export const getRecentCases = (limit = 10) => fetchAPI<any[]>(`/api/v1/cases?limit=${limit}`);
export const getLiveAlerts = () => fetchAPI<any[]>("/api/v1/alerts/live");

// Cases
export const getCases = (params?: Record<string, string>) => {
  const query = params ? "?" + new URLSearchParams(params).toString() : "";
  return fetchAPI<any[]>(`/api/v1/cases${query}`);
};
export const getCase = (id: string) => fetchAPI<any>(`/api/v1/cases/${id}`);
export const createCase = (data: any) => fetchAPI<any>("/api/v1/cases", { method: "POST", body: JSON.stringify(data) });
export const updateCase = (id: string, data: any) => fetchAPI<any>(`/api/v1/cases/${id}`, { method: "PUT", body: JSON.stringify(data) });

// Calls
export const getCalls = (params?: Record<string, string>) => {
  const query = params ? "?" + new URLSearchParams(params).toString() : "";
  return fetchAPI<any[]>(`/api/v1/calls${query}`);
};
export const getCallAnalysis = (id: string) => fetchAPI<any>(`/api/v1/calls/${id}/analysis`);
export const searchCalls = (q: string) => fetchAPI<any[]>(`/api/v1/calls/search?q=${q}`);

// SMS
export const getSmsMessages = (params?: Record<string, string>) => {
  const query = params ? "?" + new URLSearchParams(params).toString() : "";
  return fetchAPI<any[]>(`/api/v1/sms${query}`);
};
export const analyzeSms = (text: string) => fetchAPI<any>("/api/v1/sms/analyze", { method: "POST", body: JSON.stringify({ text }) });

// WhatsApp
export const getWhatsAppMessages = (params?: Record<string, string>) => {
  const query = params ? "?" + new URLSearchParams(params).toString() : "";
  return fetchAPI<any[]>(`/api/v1/whatsapp${query}`);
};

// Emergency
export const getEmergencySessions = (params?: Record<string, string>) => {
  const query = params ? "?" + new URLSearchParams(params).toString() : "";
  return fetchAPI<any[]>(`/api/v1/emergency/sessions${query}`);
};
export const resolveEmergency = (sessionId: string) => fetchAPI<any>(`/api/v1/emergency/sos/${sessionId}/resolve`, { method: "POST" });

// Bank Freeze
export const getFreezeRequests = (params?: Record<string, string>) => {
  const query = params ? "?" + new URLSearchParams(params).toString() : "";
  return fetchAPI<any[]>(`/api/v1/freeze${query}`);
};
export const createFreezeRequest = (data: any) => fetchAPI<any>("/api/v1/freeze", { method: "POST", body: JSON.stringify(data) });
export const approveFreeze = (id: string) => fetchAPI<any>(`/api/v1/freeze/approve/${id}`, { method: "POST" });
export const rejectFreeze = (id: string) => fetchAPI<any>(`/api/v1/freeze/reject/${id}`, { method: "POST" });

// Fraud Network
export const getFraudNetwork = (phone: string) => fetchAPI<any>(`/api/v1/graph/network/${phone}`);
export const getFraudRings = () => fetchAPI<any[]>("/api/v1/graph/rings");
export const searchGraph = (q: string) => fetchAPI<any[]>(`/api/v1/graph/search?q=${q}`);

// Analytics
export const getAnalytics = (period?: string) => fetchAPI<any>(`/api/v1/analytics?period=${period || "30d"}`);
export const getFraudTrends = () => fetchAPI<any>("/api/v1/analytics/trends");
export const getHeatmapData = () => fetchAPI<any>("/api/v1/analytics/heatmap");

// Evidence
export const getEvidence = (params?: Record<string, string>) => {
  const query = params ? "?" + new URLSearchParams(params).toString() : "";
  return fetchAPI<any[]>(`/api/v1/evidence${query}`);
};
export const uploadEvidence = (data: FormData) => fetchAPI<any>("/api/v1/evidence", { method: "POST", body: data, headers: {} });

// Deepfake
export const analyzeDeepfake = (data: FormData) => fetchAPI<any>("/api/v1/deepfake/analyze/voice", { method: "POST", body: data, headers: {} });
export const getDeepfakeStats = () => fetchAPI<any>("/api/v1/deepfake/stats");

// Threat Intel
export const getThreats = (params?: Record<string, string>) => {
  const query = params ? "?" + new URLSearchParams(params).toString() : "";
  return fetchAPI<any[]>(`/api/v1/threats${query}`);
};
export const getCampaigns = () => fetchAPI<any[]>("/api/v1/threats/campaigns");

// Reports
export const getReports = (type?: string) => fetchAPI<any[]>(`/api/v1/reports?type=${type || "daily"}`);
export const generateReport = (data: any) => fetchAPI<any>("/api/v1/reports/generate", { method: "POST", body: JSON.stringify(data) });

// Users
export const getUsers = () => fetchAPI<any[]>("/api/v1/users");
export const getAuditLogs = (params?: Record<string, string>) => {
  const query = params ? "?" + new URLSearchParams(params).toString() : "";
  return fetchAPI<any[]>(`/api/v1/audit${query}`);
};

// FIR
export const getFirs = (params?: Record<string, string>) => {
  const query = params ? "?" + new URLSearchParams(params).toString() : "";
  return fetchAPI<any[]>(`/api/v1/fir${query}`);
};
export const createFir = (data: any) => fetchAPI<any>("/api/v1/fir", { method: "POST", body: JSON.stringify(data) });

// Settings
export const getSettings = () => fetchAPI<any>("/api/v1/settings");
export const updateSettings = (data: any) => fetchAPI<any>("/api/v1/settings", { method: "PUT", body: JSON.stringify(data) });