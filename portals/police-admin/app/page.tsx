"use client";

import { useState, useEffect } from "react";
import {
  TrendingUp,
  TrendingDown,
  Phone,
  MessageSquare,
  AlertTriangle,
  ShieldAlert,
  Users,
  Banknote,
  Activity,
  Clock,
  ArrowUpRight,
  MapPin,
} from "lucide-react";
import { formatCurrency, formatNumber, formatDate, getRiskColor, cn } from "@/lib/utils";

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
  const [stats, setStats] = useState<DashboardStats>({
    totalCases: 1247,
    activeCases: 89,
    resolvedToday: 23,
    emergencySOS: 5,
    fraudReports: 342,
    accountsFrozen: 67,
    callsAnalyzed: 12890,
    deepfakeDetected: 34,
    totalLossPrevented: 28450000,
    citizenProtected: 45678,
  });

  const [recentCases] = useState<RecentCase[]>([
    { id: "CS-2024-0891", type: "UPI Fraud", status: "active", riskScore: 92, citizenName: "Rajesh Kumar", amount: 250000, createdAt: new Date().toISOString() },
    { id: "CS-2024-0890", type: "Call Scam", status: "resolved", riskScore: 78, citizenName: "Priya Sharma", amount: 150000, createdAt: new Date(Date.now() - 3600000).toISOString() },
    { id: "CS-2024-0889", type: "Deepfake", status: "investigating", riskScore: 95, citizenName: "Amit Patel", amount: 500000, createdAt: new Date(Date.now() - 7200000).toISOString() },
    { id: "CS-2024-0888", type: "Bank Fraud", status: "active", riskScore: 85, citizenName: "Sunita Devi", amount: 1200000, createdAt: new Date(Date.now() - 10800000).toISOString() },
    { id: "CS-2024-0887", type: "WhatsApp Scam", status: "active", riskScore: 88, citizenName: "Vikram Singh", amount: 75000, createdAt: new Date(Date.now() - 14400000).toISOString() },
  ]);

  const [alerts] = useState([
    { id: 1, message: "High-risk call pattern detected in Mumbai region", severity: "high", time: "2 min ago" },
    { id: 2, message: "New fraud campaign targeting SBI customers", severity: "critical", time: "5 min ago" },
    { id: 3, message: "Deepfake voice call reported from unknown number", severity: "high", time: "10 min ago" },
    { id: 4, message: "Emergency SOS triggered in Delhi sector 12", severity: "critical", time: "15 min ago" },
    { id: 5, message: "UPI fraud ring detected, 5 accounts frozen", severity: "medium", time: "20 min ago" },
  ]);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-2">
        <h1 className="text-3xl font-bold tracking-tight">Police Command Dashboard</h1>
        <p className="text-muted-foreground">
          Real-time cyber fraud monitoring and investigation platform
        </p>
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
            <div className="text-2xl font-bold">{stats.activeCases}</div>
            <p className="mt-1 text-xs text-muted-foreground flex items-center gap-1">
              <TrendingUp className="h-3 w-3 text-red-500" />
              <span className="text-red-500">+12%</span> from yesterday
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
            <div className="text-2xl font-bold text-destructive">{stats.emergencySOS}</div>
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
              {formatCurrency(stats.totalLossPrevented)}
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
            <div className="text-2xl font-bold text-purple-600">{stats.deepfakeDetected}</div>
            <p className="mt-1 text-xs text-muted-foreground">AI-generated voice & video</p>
          </div>
        </div>
      </div>

      {/* Secondary Stats */}
      <div className="grid gap-4 grid-cols-2 md:grid-cols-4 lg:grid-cols-6">
        <div className="glass-card p-3 text-center">
          <div className="text-lg font-bold">{formatNumber(stats.callsAnalyzed)}</div>
          <div className="text-xs text-muted-foreground flex items-center justify-center gap-1">
            <Phone className="h-3 w-3" /> Calls Analyzed
          </div>
        </div>
        <div className="glass-card p-3 text-center">
          <div className="text-lg font-bold">{stats.accountsFrozen}</div>
          <div className="text-xs text-muted-foreground flex items-center justify-center gap-1">
            <Banknote className="h-3 w-3" /> Accounts Frozen
          </div>
        </div>
        <div className="glass-card p-3 text-center">
          <div className="text-lg font-bold">{formatNumber(stats.fraudReports)}</div>
          <div className="text-xs text-muted-foreground">Fraud Reports</div>
        </div>
        <div className="glass-card p-3 text-center">
          <div className="text-lg font-bold">{stats.resolvedToday}</div>
          <div className="text-xs text-muted-foreground text-green-500">Resolved Today</div>
        </div>
        <div className="glass-card p-3 text-center">
          <div className="text-lg font-bold">{stats.totalCases}</div>
          <div className="text-xs text-muted-foreground">Total Cases</div>
        </div>
        <div className="glass-card p-3 text-center">
          <div className="text-lg font-bold">{formatNumber(stats.citizenProtected)}</div>
          <div className="text-xs text-muted-foreground">Citizens Protected</div>
        </div>
      </div>

      {/* Main Content Grid */}
      <div className="grid gap-6 lg:grid-cols-3">
        {/* Recent Cases */}
        <div className="lg:col-span-2 stat-card">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold">Recent High-Risk Cases</h2>
            <button className="text-sm text-primary hover:underline flex items-center gap-1">
              View All <ArrowUpRight className="h-3 w-3" />
            </button>
          </div>
          <div className="space-y-3">
            {recentCases.map((case_) => (
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
                    "text-green-500": case_.status === "resolved",
                    "text-yellow-500": case_.status === "active",
                    "text-blue-500": case_.status === "investigating",
                  })}>
                    {case_.status}
                  </span>
                  <p className="text-xs text-muted-foreground mt-1">{formatDate(case_.createdAt)}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Live Alerts & Quick Actions */}
        <div className="space-y-6">
          {/* Live Alerts */}
          <div className="stat-card">
            <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <AlertTriangle className="h-4 w-4 text-destructive alert-pulse" />
              Live Alerts
            </h2>
            <div className="space-y-3">
              {alerts.map((alert) => (
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
              ))}
            </div>
          </div>

          {/* Quick Actions */}
          <div className="stat-card">
            <h2 className="text-lg font-semibold mb-4">Quick Actions</h2>
            <div className="grid grid-cols-2 gap-2">
              <button className="p-3 rounded-lg border bg-card/50 hover:bg-accent text-sm text-left">
                <ShieldAlert className="h-4 w-4 text-destructive mb-1" />
                Trigger SOS
              </button>
              <button className="p-3 rounded-lg border bg-card/50 hover:bg-accent text-sm text-left">
                <Banknote className="h-4 w-4 text-primary mb-1" />
                Freeze Account
              </button>
              <button className="p-3 rounded-lg border bg-card/50 hover:bg-accent text-sm text-left">
                <Phone className="h-4 w-4 text-primary mb-1" />
                Analyze Call
              </button>
              <button className="p-3 rounded-lg border bg-card/50 hover:bg-accent text-sm text-left">
                <MapPin className="h-4 w-4 text-primary mb-1" />
                View Heatmap
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* National Statistics */}
      <div className="stat-card">
        <h2 className="text-lg font-semibold mb-4">National Fraud Statistics</h2>
        <div className="grid gap-4 md:grid-cols-4">
          <div className="text-center p-4 rounded-lg bg-blue-50 dark:bg-blue-950/50">
            <div className="text-2xl font-bold text-blue-600">₹1,284 Cr</div>
            <div className="text-xs text-muted-foreground mt-1">Total Loss Prevented</div>
          </div>
          <div className="text-center p-4 rounded-lg bg-green-50 dark:bg-green-950/50">
            <div className="text-2xl font-bold text-green-600">45,678</div>
            <div className="text-xs text-muted-foreground mt-1">Citizens Protected</div>
          </div>
          <div className="text-center p-4 rounded-lg bg-purple-50 dark:bg-purple-950/50">
            <div className="text-2xl font-bold text-purple-600">12,890</div>
            <div className="text-xs text-muted-foreground mt-1">Calls Analyzed</div>
          </div>
          <div className="text-center p-4 rounded-lg bg-orange-50 dark:bg-orange-950/50">
            <div className="text-2xl font-bold text-orange-600">342</div>
            <div className="text-xs text-muted-foreground mt-1">Fraud Campaigns</div>
          </div>
        </div>
      </div>
    </div>
  );
}