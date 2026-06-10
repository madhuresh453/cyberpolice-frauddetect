"use client";

import { BarChart3, TrendingUp, TrendingDown, Activity } from "lucide-react";
import { cn } from "@/lib/utils";

export default function AnalyticsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight flex items-center gap-3">
          <BarChart3 className="h-8 w-8 text-primary" />
          Analytics
        </h1>
        <p className="text-muted-foreground mt-1">Fraud trends, risk distribution, and attack source analytics</p>
      </div>
      <div className="grid gap-4 md:grid-cols-4">
        {[
          { label: "Total Fraud Cases", value: "12,489", change: "+8%", up: true },
          { label: "Amount Lost", value: "₹28.4 Cr", change: "-12%", up: false },
          { label: "Resolution Rate", value: "67%", change: "+5%", up: true },
          { label: "Avg Response Time", value: "4.2h", change: "-18%", up: false },
        ].map((s) => (
          <div key={s.label} className="stat-card">
            <p className="text-sm text-muted-foreground">{s.label}</p>
            <div className="flex items-end justify-between mt-2">
              <p className="text-2xl font-bold">{s.value}</p>
              <span className={cn("text-xs flex items-center gap-1", s.up ? "text-emerald-400" : "text-red-400")}>
                {s.up ? <TrendingUp className="h-3 w-3" /> : <TrendingDown className="h-3 w-3" />}
                {s.change}
              </span>
            </div>
          </div>
        ))}
      </div>
      <div className="grid gap-6 lg:grid-cols-2">
        <div className="stat-card">
          <h2 className="text-lg font-semibold mb-4">Fraud by Type</h2>
          <div className="space-y-3">
            {[
              { type: "UPI Fraud", count: 4521, pct: 36 },
              { type: "Call Scam", count: 3210, pct: 26 },
              { type: "Phishing", count: 2100, pct: 17 },
              { type: "Deepfake", count: 1200, pct: 10 },
              { type: "Other", count: 1458, pct: 11 },
            ].map((item) => (
              <div key={item.type}>
                <div className="flex items-center justify-between text-sm mb-1">
                  <span>{item.type}</span>
                  <span className="text-muted-foreground">{item.count.toLocaleString()} ({item.pct}%)</span>
                </div>
                <div className="h-2 rounded-full bg-muted overflow-hidden">
                  <div className="h-full rounded-full bg-gradient-to-r from-primary to-cyan" style={{ width: `${item.pct}%` }} />
                </div>
              </div>
            ))}
          </div>
        </div>
        <div className="stat-card">
          <h2 className="text-lg font-semibold mb-4">Attack Sources by State</h2>
          <div className="space-y-2">
            {[
              { state: "Maharashtra", cases: 2340 },
              { state: "Delhi", cases: 1890 },
              { state: "Karnataka", cases: 1456 },
              { state: "Tamil Nadu", cases: 1230 },
              { state: "Gujarat", cases: 987 },
              { state: "Uttar Pradesh", cases: 876 },
            ].map((item, i) => (
              <div key={item.state} className="flex items-center gap-3 p-2 rounded-lg bg-muted/30">
                <span className="text-xs font-bold text-muted-foreground w-6">{i + 1}</span>
                <span className="text-sm flex-1">{item.state}</span>
                <span className="text-sm font-medium">{item.cases.toLocaleString()}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}