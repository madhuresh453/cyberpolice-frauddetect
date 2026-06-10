"use client";

import { useState } from "react";
import { FileText, Plus, Search, Download, CheckCircle, Clock, Edit, Filter } from "lucide-react";
import { cn } from "@/lib/utils";

export default function FirPage() {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight flex items-center gap-3">
            <FileText className="h-8 w-8 text-primary" />
            FIR Management
          </h1>
          <p className="text-muted-foreground mt-1">Generate, edit, and manage First Information Reports</p>
        </div>
        <button className="cyber-button flex items-center gap-2"><Plus className="h-4 w-4" /> Generate FIR</button>
      </div>
      <div className="grid gap-4 md:grid-cols-4">
        {[
          { label: "Total FIRs", value: "1,892", color: "blue" },
          { label: "Pending Approval", value: "34", color: "amber" },
          { label: "Approved Today", value: "12", color: "emerald" },
          { label: "Digital Signed", value: "1,856", color: "purple" },
        ].map((s) => (
          <div key={s.label} className="stat-card">
            <p className="text-sm text-muted-foreground">{s.label}</p>
            <p className={cn("text-2xl font-bold mt-1", `text-${s.color}-500`)}>{s.value}</p>
          </div>
        ))}
      </div>
      <div className="stat-card">
        <h2 className="text-lg font-semibold mb-4">FIR Records</h2>
        <div className="space-y-2">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className="flex items-center gap-4 p-3 rounded-lg border border-border/50 bg-card/50 hover:bg-accent/30 transition-colors">
              <FileText className="h-5 w-5 text-muted-foreground shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <span className="text-sm font-medium">FIR-{2024000 + i}</span>
                  <span className={cn("text-xs px-2 py-0.5 rounded-full",
                    i % 3 === 0 ? "bg-amber-500/10 text-amber-400" : "bg-emerald-500/10 text-emerald-400"
                  )}>
                    {i % 3 === 0 ? "Pending" : "Approved"}
                  </span>
                </div>
                <p className="text-xs text-muted-foreground">Section 420/468 — {["Rajesh Kumar", "Priya Sharma", "Amit Patel"][i % 3]} — CS-2024-{1200 + i}</p>
              </div>
              <div className="flex gap-2">
                <button className="p-1.5 rounded-md bg-primary/10 text-primary hover:bg-primary/20"><Edit className="h-3 w-3" /></button>
                <button className="p-1.5 rounded-md bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20"><Download className="h-3 w-3" /></button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}