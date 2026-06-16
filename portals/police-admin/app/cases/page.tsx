"use client";
import { useState, useEffect } from "react";
import { Search, AlertTriangle, ChevronLeft, ChevronRight } from "lucide-react";
import { cn } from "@/lib/utils";

const API = process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api/v1";

function getHeaders() {
  const token = typeof window !== "undefined" ? localStorage.getItem("jwt_token") : "";
  return { Authorization: `Bearer ${token}`, "Content-Type": "application/json" };
}

export default function CasesPage() {
  const [cases, setCases] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("");

  useEffect(() => { fetchCases(); }, [page, statusFilter]);

  async function fetchCases() {
    setLoading(true);
    try {
      const params = new URLSearchParams({ page: String(page), limit: "20" });
      if (statusFilter) params.set("status", statusFilter);
      const res = await fetch(`${API}/police/cases?${params}`, { headers: getHeaders() });
      const data = await res.json();
      const caseList = data.data || data.cases || data || [];
      setCases(Array.isArray(caseList) ? caseList : []);
      setTotal(data.pagination?.total || caseList.length || 0);
    } catch (e) { console.error(e); }
    setLoading(false);
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Case Management</h1>
          <p className="text-muted-foreground text-sm">{total} cases found</p>
        </div>
        <div className="flex gap-3">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
            <input className="input-field pl-9 w-64" placeholder="Search cases..." value={search} onChange={e => setSearch(e.target.value)} />
          </div>
          <select className="input-field w-36" value={statusFilter} onChange={e => { setStatusFilter(e.target.value); setPage(1); }}>
            <option value="">All Status</option>
            <option value="open">Open</option>
            <option value="investigating">Investigating</option>
            <option value="closed">Closed</option>
          </select>
        </div>
      </div>

      {loading ? (
        <div className="space-y-3">{[...Array(5)].map((_, i) => <div key={i} className="stat-card animate-pulse h-16" />)}</div>
      ) : cases.length === 0 ? (
        <div className="stat-card text-center py-16">
          <AlertTriangle className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
          <p className="text-muted-foreground">No cases found</p>
        </div>
      ) : (
        <div className="space-y-3">
          {cases.map((c: any) => (
            <div key={c.id || c._id} className="stat-card hover:border-primary/50 cursor-pointer transition-all">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-4">
                  <div className={cn("w-2 h-2 rounded-full", {
                    "bg-yellow-400": c.status === "open",
                    "bg-green-400": c.status === "closed" || c.status === "resolved",
                    "bg-blue-400": c.status === "investigating",
                  })} />
                  <div>
                    <span className="font-mono text-primary text-sm">{c.case_number || c.caseId}</span>
                    <h3 className="font-medium">{c.title || c.fraudType || "Untitled Case"}</h3>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <span className={cn("text-xs font-medium px-2 py-0.5 rounded-full", {
                    "bg-red-100 text-red-700": c.priority === "critical",
                    "bg-yellow-100 text-yellow-700": c.priority === "high",
                    "bg-green-100 text-green-700": c.priority === "low" || c.priority === "medium",
                  })}>
                    {c.priority || "medium"}
                  </span>
                  <span className="text-xs text-muted-foreground">{c.risk_score || c.riskScore || 0} risk</span>
                  <span className="text-xs text-muted-foreground">{new Date(c.created_at || c.createdAt).toLocaleDateString()}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {total > 20 && (
        <div className="flex items-center justify-center gap-4 mt-6">
          <button disabled={page <= 1} onClick={() => setPage(p => p - 1)} className="btn-outline disabled:opacity-30">
            <ChevronLeft className="w-4 h-4" /> Previous
          </button>
          <span className="text-sm text-muted-foreground">Page {page} of {Math.ceil(total / 20)}</span>
          <button disabled={page >= Math.ceil(total / 20)} onClick={() => setPage(p => p + 1)} className="btn-outline disabled:opacity-30">
            Next <ChevronRight className="w-4 h-4" />
          </button>
        </div>
      )}
    </div>
  );
}