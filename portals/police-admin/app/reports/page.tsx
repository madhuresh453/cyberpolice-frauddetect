"use client";

import { useState } from "react";
import { FileText, Download, Calendar, Filter, FileDown, BarChart3 } from "lucide-react";
import { cn } from "@/lib/utils";

export default function ReportsPage() {
  const [reportType, setReportType] = useState("daily");
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight flex items-center gap-3">
            <FileText className="h-8 w-8 text-primary" />
            Reports
          </h1>
          <p className="text-muted-foreground mt-1">Generate and export fraud investigation reports</p>
        </div>
        <button className="cyber-button flex items-center gap-2"><FileDown className="h-4 w-4" /> Export Report</button>
      </div>
      <div className="flex gap-2 p-1 rounded-lg border border-border bg-card w-fit">
        {["daily", "weekly", "monthly", "custom"].map((t) => (
          <button
            key={t}
            onClick={() => setReportType(t)}
            className={cn("px-4 py-2 rounded-md text-sm font-medium transition-colors capitalize",
              reportType === t ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground"
            )}
          >
            {t}
          </button>
        ))}
      </div>
      <div className="grid gap-4 md:grid-cols-4">
        {[
          { label: "Total Reports", value: "1,230", color: "blue" },
          { label: "Generated Today", value: "45", color: "emerald" },
          { label: "Pending Review", value: "12", color: "amber" },
          { label: "Exported", value: "890", color: "purple" },
        ].map((s) => (
          <div key={s.label} className="stat-card">
            <p className="text-sm text-muted-foreground">{s.label}</p>
            <p className={cn("text-2xl font-bold mt-1", `text-${s.color}-500`)}>{s.value}</p>
          </div>
        ))}
      </div>
      <div className="stat-card">
        <h2 className="text-lg font-semibold mb-4">Recent Reports</h2>
        <div className="space-y-2">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className="flex items-center gap-4 p-3 rounded-lg border border-border/50 bg-card/50 hover:bg-accent/30 transition-colors">
              <FileText className="h-5 w-5 text-muted-foreground shrink-0" />
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium">Report-{2024000 + i} — {["Daily Summary", "Weekly Digest", "Monthly Analysis", "Fraud Breakdown"][i % 4]}</p>
                <p className="text-xs text-muted-foreground">Generated: Jun {9 - i}, 2024 — {50 + i * 12} cases covered</p>
              </div>
              <button className="px-3 py-1.5 rounded-md bg-primary/10 text-primary text-xs font-medium hover:bg-primary/20 flex items-center gap-1">
                <Download className="h-3 w-3" /> CSV
              </button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}