"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { FileText, Search, Plus, Filter, ChevronRight, Clock, User, AlertTriangle, CheckCircle, ArrowUpDown } from "lucide-react";
import { cn } from "@/lib/utils";

export default function CasesPage() {
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const statuses = ["all", "open", "investigating", "resolved", "closed"];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight flex items-center gap-3">
            <FileText className="h-8 w-8 text-primary" />
            Case Management
          </h1>
          <p className="text-muted-foreground mt-1">Track and manage cyber fraud investigations</p>
        </div>
        <button className="cyber-button flex items-center gap-2">
          <Plus className="h-4 w-4" /> New Case
        </button>
      </div>
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <input
            type="text"
            placeholder="Search cases by ID, citizen, or keyword..."
            className="w-full pl-10 pr-4 py-2.5 rounded-lg border border-border bg-card text-sm focus:outline-none focus:ring-2 focus:ring-primary/50"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
        <div className="flex gap-1 p-1 rounded-lg border border-border bg-card">
          {statuses.map((s) => (
            <button
              key={s}
              onClick={() => setStatusFilter(s)}
              className={cn("px-3 py-1.5 rounded-md text-xs font-medium transition-colors capitalize",
                statusFilter === s ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground"
              )}
            >
              {s}
            </button>
          ))}
        </div>
      </div>
      <div className="grid gap-4 md:grid-cols-4">
        {[
          { label: "Open Cases", value: "89", color: "blue" },
          { label: "Investigating", value: "45", color: "amber" },
          { label: "Resolved Today", value: "12", color: "emerald" },
          { label: "High Priority", value: "23", color: "red" },
        ].map((s) => (
          <div key={s.label} className="stat-card">
            <p className="text-sm text-muted-foreground">{s.label}</p>
            <p className={cn("text-2xl font-bold mt-1", `text-${s.color}-500`)}>{s.value}</p>
          </div>
        ))}
      </div>
      <div className="stat-card">
        <div className="space-y-2">
          {Array.from({ length: 10 }).map((_, i) => (
            <div key={i} className="flex items-center gap-4 p-4 rounded-lg border border-border/50 bg-card/50 hover:bg-accent/30 transition-colors cursor-pointer">
              <div className={cn("h-10 w-10 rounded-lg flex items-center justify-center shrink-0",
                i % 3 === 0 ? "bg-red-500/10" : i % 3 === 1 ? "bg-amber-500/10" : "bg-emerald-500/10"
              )}>
                <FileText className={cn("h-5 w-5",
                  i % 3 === 0 ? "text-red-400" : i % 3 === 1 ? "text-amber-400" : "text-emerald-400"
                )} />
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <span className="text-sm font-medium">CS-2024-{String(1200 + i).padStart(4, "0")}</span>
                  <span className={cn("text-xs px-2 py-0.5 rounded-full capitalize",
                    i % 3 === 0 ? "bg-red-500/10 text-red-400" : i % 3 === 1 ? "bg-amber-500/10 text-amber-400" : "bg-emerald-500/10 text-emerald-400"
                  )}>
                    {["Open", "Investigating", "Resolved"][i % 3]}
                  </span>
                </div>
                <p className="text-xs text-muted-foreground mt-0.5">
                  {["UPI Fraud", "Call Scam", "Bank Fraud", "Deepfake", "Phishing"][i % 5]} — {["Rajesh Kumar", "Priya Sharma", "Amit Patel", "Sunita Devi", "Vikram Singh"][i % 5]}
                </p>
              </div>
              <div className="text-right hidden sm:block">
                <p className="text-xs text-muted-foreground">{i + 1}h ago</p>
                <p className="text-xs font-medium mt-0.5">Risk: {60 + i * 3}/100</p>
              </div>
              <ChevronRight className="h-4 w-4 text-muted-foreground shrink-0" />
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}