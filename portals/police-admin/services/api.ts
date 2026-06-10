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
