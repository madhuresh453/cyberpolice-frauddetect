"use client";

import { Brain, AlertTriangle, Shield, Search, Filter, ExternalLink } from "lucide-react";
import { cn } from "@/lib/utils";

export default function ThreatIntelPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight flex items-center gap-3">
          <Brain className="h-8 w-8 text-purple-500" />
          Threat Intelligence
        </h1>
        <p className="text-muted-foreground mt-1">Active threat campaigns, IOCs, and fraud intelligence</p>
      </div>
      <div className="grid gap-4 md:grid-cols-4">
        {[
          { label: "Active Campaigns", value: "18", color: "red" },
          { label: "IOCs Tracked", value: "2,340", color: "amber" },
          { label: "Blacklisted Numbers", value: "12,890", color: "purple" },
          { label: "Threat Level", value: "HIGH", color: "red" },
        ].map((s) => (
          <div key={s.label} className="stat-card">
            <p className="text-sm text-muted-foreground">{s.label}</p>
            <p className={cn("text-2xl font-bold mt-1", `text-${s.color}-500`)}>{s.value}</p>
          </div>
        ))}
      </div>
      <div className="stat-card">
        <h2 className="text-lg font-semibold mb-4">Active Fraud Campaigns</h2>
        <div className="space-y-3">
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className="p-4 rounded-lg border border-red-500/20 bg-red-500/5">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <AlertTriangle className="h-4 w-4 text-red-400" />
                  <span className="text-sm font-medium">{["SBI KYC Fraud Wave", "UPI Fake Payment Scam", "Amazon Gift Card Phishing", "Police Impersonation", "Crypto Investment Fraud", "Tax Refund Scam"][i]}</span>
                </div>
                <span className="text-xs px-2 py-0.5 rounded-full bg-red-500/20 text-red-400">ACTIVE</span>
              </div>
              <p className="text-xs text-muted-foreground">Affecting {500 + i * 340} citizens — Estimated loss: ₹{(50 + i * 30).toLocaleString("en-IN")} Lakh</p>
              <div className="flex gap-2 mt-2">
                <button className="text-xs text-primary hover:underline">View Details</button>
                <button className="text-xs text-muted-foreground hover:text-foreground">Block IOCs</button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}