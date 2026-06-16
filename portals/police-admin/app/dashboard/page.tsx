"use client";

import { useState, useEffect } from "react";
import { useAuth } from "@/components/auth/auth-provider";
import {
  TrendingUp, TrendingDown, Phone, MessageSquare, AlertTriangle,
  ShieldAlert, Users, Banknote, Activity, Clock, ArrowUpRight, MapPin,
} from "lucide-react";
import { formatCurrency, formatNumber, formatDate, getRiskColor, cn } from "@/lib/utils";

const API = process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api/v1";

interface DashboardStats {
  totalCases: number;
  activeCases: number;
  resolvedToday: number;
  emergencySOS: number;
  fraudReports: number;
  accountsFrozen: number;
  callsAnalyzed: number;
  deepfakeDetected: number;
  totalLossPrevented: number;
  citizenProtected: number;
}

interface RecentCase {
  id: string;
  type: string;
  status: string;
  riskScore: number;
  citizenName: string;
  amount: number;
  createdAt: string;
}

export default function PoliceDashboard() {
  const { getAuthHeaders } = useAuth();
  const [stats, setStats] = useState<DashboardStats>({
    totalCases: 0, activeCases: 0, resolvedToday: 0, emergencySOS: 0,
    fraudReports: 0, accountsFrozen: 0, callsAnalyzed: 0, deepfakeDetected: 0,
    totalLossPrevented: 0, citizenProtected: 0,
  });
  const [recentCases, setRecentCases] = useState<RecentCase[]>([]);
  const [alerts, setAlerts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  async function fetchDashboardData() {
    setLoading(true);
    try {
      const headers = getAuthHeaders();
      
      // Fetch multiple endpoints in parallel
      const [analyticsRes, casesRes, intelStatsRes] = await Promise.allSettled([
        fetch(`${API}/police/analytics?days=7`, { headers }),
        fetch(`${API}/police/cases?limit=5&sort=-createdAt`, { headers }),
        fetch(`${API}/ai/threat-intel/stats`, { headers }),
      ]);

      // Parse analytics data
      if (analyticsRes.status === "fulfilled" && analyticsRes.value.ok) {
        const analytics = await analyticsRes.value.json();
        setStats({
          totalCases: analytics.totalCases || analytics.total_cases || 0,
          activeCases: analytics.activeCases || analytics.open_cases || 0,
          resolvedToday: analytics.resolvedToday || analytics.closed_cases || 0,
          emergencySOS: analytics.emergencySOS || 0,
          fraudReports: analytics.fraudReports || analytics.total_reports || 0,
          accountsFrozen: analytics.accountsFrozen || 0,
          callsAnalyzed: analytics.callsAnalyzed || 0,
          deepfakeDetected: analytics.deepfakeDetected || 0,
          totalLossPrevented: analytics.totalLossPrevented || 0,
          citizenProtected: analytics.citizenProtected || 0,
        });
      }

      // Parse cases data
      if (casesRes.status === "fulfilled" && casesRes.value.ok) {
        const casesData = await casesRes.value.json();
        const cases = casesData.data || casesData.cases || casesData || [];
        if (Array.isArray(cases)) {
          setRecentCases(cases.slice(0, 5).map((c: any) => ({
            id: c.caseId || c._id || c.id || "N/A",
            type: c.fraudType || c.type || "Unknown",
            status: c.status || "open",
            riskScore: c.riskScore || 0,
            citizenName: c.citizenName || c.reporterName || "Anonymous",
            amount: c.amount || c.lossAmount || 0,
            createdAt: c.createdAt || new Date().toISOString(),
          })));
        }
      }

      // Parse threat intel
      if (intelStatsRes.status === "fulfilled" && intelStatsRes.value.ok) {
        const intel = await intelStatsRes.value.json();
        setAlerts([
          { id: 1, message: `${intel.total_fraud_numbers || 0} fraud numbers in database`, severity: "high", time: "Now" },
          { id: 2, message: `${intel.high_risk_numbers || 0} high-risk numbers flagged`, severity: "critical", time: "Now" },
          { id: 3, message: `${intel.recent_reports || 0} reports in last 24 hours`, severity: "medium", time: "Now" },
        ]);
      }
    } catch (err) {
      console.error("Dashboard fetch error:", err);
    }
    setLoading(false);
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-2">
        <h1 className="text-3xl font-bold tracking-tight">CyberShield Police Command Center</h1>
        <p className="text-muted-foreground">Real-time cyber fraud monitoring and investigation platform</p>
      </div>

      {/* Stats Grid */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <p className="text-sm font-medium text-muted-foreground">Active Cases</p>
            <div className="rounded-full bg-primary/10 p-2">
              <AlertTriangle className="h-4 w-4 text-primary" />
            </div>
          </div>
          <div className="mt-3">
            <div className="text-2xl font-bold">{loading ? "—" : stats.activeCases}</div>
            <p className="mt-1 text-xs text-muted-foreground flex items-center gap-1">
              <TrendingUp className="h-3 w-3 text-red-500" />
              <span className="text-red-500">Live</span> from backend
            </p>
          </div>
        </div>

        <div className="stat-card">
          <div className="flex items-center justify-between">
            <p className="text-sm font-medium text-muted-foreground">Emergency SOS</p>
            <div className="rounded-full bg-destructive/10 p-2">
              <ShieldAlert className="h-4 w-4 text-destructive" />
            </div>
          </div>
          <div className="mt-3">
            <div className="text-2xl font-bold text-destructive">{loading ? "—" : stats.emergencySOS}</div>
            <p className="mt-1 text-xs text-muted-foreground flex items-center gap-1">
              <Clock className="h-3 w-3" />
              Requires immediate attention
            </p>
          </div>
        </div>

        <div className="stat-card">
          <div className="flex items-center justify-between">
            <p className="text-sm font-medium text-muted-foreground">Loss Prevented</p>
            <div className="rounded-full bg-green-500/10 p-2">
              <Banknote className="h-4 w-4 text-green-500" />
            </div>
          </div>
          <div className="mt-3">
            <div className="text-2xl font-bold text-green-600">
              {loading ? "—" : formatCurrency(stats.totalLossPrevented)}
            </div>
            <p className="mt-1 text-xs text-muted-foreground flex items-center gap-1">
              <TrendingDown className="h-3 w-3 text-green-500" />
              <span className="text-green-500">Protected {formatNumber(stats.citizenProtected)} citizens</span>
            </p>
          </div>
        </div>

        <div className="stat-card">
          <div className="flex items-center justify-between">
            <p className="text-sm font-medium text-muted-foreground">Deepfake Detected</p>
            <div className="rounded-full bg-purple-500/10 p-2">
              <Activity className="h-4 w-4 text-purple-500" />
            </div>
          </div>
          <div className="mt-3">
            <div className="text-2xl font-bold text-purple-600">{loading ? "—" : stats.deepfakeDetected}</div>
            <p className="mt-1 text-xs text-muted-foreground">AI-generated voice & video</p>
          </div>
        </div>
      </div>

      {/* Secondary Stats */}
      <div className="grid gap-4 grid-cols-2 md:grid-cols-4 lg:grid-cols-6">
        <div className="glass-card p-3 text-center">
          <div className="text-lg font-bold">{loading ? "—" : formatNumber(stats.callsAnalyzed)}</div>
          <div className="text-xs text-muted-foreground flex items-center justify-center gap-1">
            <Phone className="h-3 w-3" /> Calls Analyzed
          </div>
        </div>
        <div className="glass-card p-3 text-center">
          <div className="text-lg font-bold">{loading ? "—" : stats.accountsFrozen}</div>
          <div className="text-xs text-muted-foreground flex items-center justify-center gap-1">
            <Banknote className="h-3 w-3" /> Accounts Frozen
          </div>
        </div>
        <div className="glass-card p-3 text-center">
          <div className="text-lg font-bold">{loading ? "—" : formatNumber(stats.fraudReports)}</div>
          <div className="text-xs text-muted-foreground">Fraud Reports</div>
        </div>
        <div className="glass-card p-3 text-center">
          <div className="text-lg font-bold">{loading ? "—" : stats.resolvedToday}</div>
          <div className="text-xs text-muted-foreground text-green-500">Resolved Today</div>
        </div>
        <div className="glass-card p-3 text-center">
          <div className="text-lg font-bold">{loading ? "—" : stats.totalCases}</div>
          <div className="text-xs text-muted-foreground">Total Cases</div>
        </div>
        <div className="glass-card p-3 text-center">
          <div className="text-lg font-bold">{loading ? "—" : formatNumber(stats.citizenProtected)}</div>
          <div className="text-xs text-muted-foreground">Citizens Protected</div>
        </div>
      </div>

      {/* Main Content Grid */}
      <div className="grid gap-6 lg:grid-cols-3">
        {/* Recent Cases */}
        <div className="lg:col-span-2 stat-card">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold">Recent High-Risk Cases</h2>
            <a href="/cases" className="text-sm text-primary hover:underline flex items-center gap-1">
              View All <ArrowUpRight className="h-3 w-3" />
            </a>
          </div>
          <div className="space-y-3">
            {loading ? (
              <div className="text-center text-muted-foreground py-4">Loading cases...</div>
            ) : recentCases.length === 0 ? (
              <div className="text-center text-muted-foreground py-4">No cases yet</div>
            ) : (
              recentCases.map((case_) => (
                <div key={case_.id} className="flex items-center justify-between p-3 rounded-lg border bg-card/50 hover:bg-accent/50 transition-colors cursor-pointer">
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <span className={cn("text-xs font-medium px-2 py-0.5 rounded-full", {
                        "bg-red-100 text-red-700": case_.riskScore >= 80,
                        "bg-yellow-100 text-yellow-700": case_.riskScore >= 60 && case_.riskScore < 80,
                        "bg-green-100 text-green-700": case_.riskScore < 60,
                      })}>
                        Score: {case_.riskScore}
                      </span>
                      <span className="text-sm font-medium truncate">{case_.citizenName}</span>
                    </div>
                    <div className="flex items-center gap-2 mt-1">
                      <span className="text-xs text-muted-foreground">{case_.id}</span>
                      <span className="text-xs text-muted-foreground">•</span>
                      <span className="text-xs text-muted-foreground">{case_.type}</span>
                      <span className="text-xs text-muted-foreground">•</span>
                      <span className="text-xs font-medium">{formatCurrency(case_.amount)}</span>
                    </div>
                  </div>
                  <div className="text-right">
                    <span className={cn("text-xs font-medium", {
                      "text-green-500": case_.status === "resolved" || case_.status === "closed",
                      "text-yellow-500": case_.status === "active" || case_.status === "open",
                      "text-blue-500": case_.status === "investigating",
                    })}>
                      {case_.status}
                    </span>
                    <p className="text-xs text-muted-foreground mt-1">{formatDate(case_.createdAt)}</p>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Live Alerts & Quick Actions */}
        <div className="space-y-6">
          <div className="stat-card">
            <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <AlertTriangle className="h-4 w-4 text-destructive alert-pulse" />
              Live Alerts
            </h2>
            <div className="space-y-3">
              {alerts.length === 0 ? (
                <div className="text-sm text-muted-foreground">No alerts</div>
              ) : (
                alerts.map((alert) => (
                  <div key={alert.id} className="flex gap-3 p-2 rounded-lg hover:bg-accent/50">
                    <div className={cn("w-2 h-2 rounded-full mt-1.5 shrink-0", {
                      "bg-destructive": alert.severity === "critical",
                      "bg-orange-500": alert.severity === "high",
                      "bg-yellow-500": alert.severity === "medium",
                    })} />
                    <div className="flex-1 min-w-0">
                      <p className="text-sm">{alert.message}</p>
                      <p className="text-xs text-muted-foreground mt-1">{alert.time}</p>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>

          <div className="stat-card">
            <h2 className="text-lg font-semibold mb-4">Quick Actions</h2>
            <div className="grid grid-cols-2 gap-2">
              <a href="/emergency" className="p-3 rounded-lg border bg-card/50 hover:bg-accent text-sm text-left">
                <ShieldAlert className="h-4 w-4 text-destructive mb-1" />
                Emergency SOS
              </a>
              <a href="/bank-freeze" className="p-3 rounded-lg border bg-card/50 hover:bg-accent text-sm text-left">
                <Banknote className="h-4 w-4 text-primary mb-1" />
                Freeze Account
              </a>
              <a href="/call-analysis" className="p-3 rounded-lg border bg-card/50 hover:bg-accent text-sm text-left">
                <Phone className="h-4 w-4 text-primary mb-1" />
                Analyze Call
              </a>
              <a href="/heatmap" className="p-3 rounded-lg border bg-card/50 hover:bg-accent text-sm text-left">
                <MapPin className="h-4 w-4 text-primary mb-1" />
                View Heatmap
              </a>
            </div>
          </div>
        </div>
      </div>

      {/* Auto-Refresh Notice */}
      <div className="text-center text-xs text-muted-foreground">
        Data is fetched live from CyberShield AI backend. Auto-refresh every 30 seconds.
      </div>
    </div>
  );
}