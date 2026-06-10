"use client";

import { useState } from "react";
import { Shield, Search, AlertTriangle, Image, Link, Users, Filter, CheckCircle, XCircle } from "lucide-react";
import { cn } from "@/lib/utils";

export default function WhatsAppAnalysisPage() {
  const [searchQuery, setSearchQuery] = useState("");
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight flex items-center gap-3">
          <Shield className="h-8 w-8 text-emerald-500" />
          WhatsApp Analysis
        </h1>
        <p className="text-muted-foreground mt-1">WhatsApp chat analysis, voice note analysis, and scam detection</p>
      </div>
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <input
            type="text"
            placeholder="Search WhatsApp messages, groups, or contacts..."
            className="w-full pl-10 pr-4 py-2.5 rounded-lg border border-border bg-card text-sm focus:outline-none focus:ring-2 focus:ring-primary/50"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
        <button className="px-4 py-2.5 rounded-lg border border-border bg-card text-sm hover:bg-accent flex items-center gap-2">
          <Filter className="h-4 w-4" /> Filters
        </button>
      </div>
      <div className="grid gap-4 md:grid-cols-4">
        {[
          { label: "Messages Scanned", value: "24,500", icon: Shield },
          { label: "Fraud Detected", value: "1,230", icon: AlertTriangle },
          { label: "Links Scanned", value: "8,900", icon: Link },
          { label: "Media Analyzed", value: "3,400", icon: Image },
        ].map((s) => (
          <div key={s.label} className="stat-card">
            <div className="flex items-center justify-between">
              <p className="text-sm text-muted-foreground">{s.label}</p>
              <s.icon className="h-4 w-4 text-primary" />
            </div>
            <p className="text-2xl font-bold mt-2">{s.value}</p>
          </div>
        ))}
      </div>
      <div className="stat-card">
        <h2 className="text-lg font-semibold mb-4">Recent WhatsApp Analysis</h2>
        <div className="space-y-2">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className={cn("p-4 rounded-lg border", i % 3 === 0 ? "border-red-500/20 bg-red-500/5" : "border-border/50 bg-card/50")}>
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <Users className="h-4 w-4 text-muted-foreground" />
                  <span className="text-sm font-medium">{["Scam Group #45", "Job Offer Fraud", "Investment Scam", "Lottery Scam Group", "KYC Scam", "Crypto Fraud", "Tax Refund Scam", "Delivery Scam"][i]}</span>
                </div>
                {i % 3 === 0 ? <XCircle className="h-4 w-4 text-red-400" /> : <CheckCircle className="h-4 w-4 text-emerald-400" />}
              </div>
              <p className="text-sm text-muted-foreground">Group with {50 + i * 23} members — {i % 3 === 0 ? "fraud patterns detected" : "no threats found"}</p>
              <div className="flex items-center gap-2 mt-2">
                <span className={cn("text-xs px-2 py-0.5 rounded-full", i % 3 === 0 ? "bg-red-500/10 text-red-400" : "bg-emerald-500/10 text-emerald-400")}>
                  {i % 3 === 0 ? "HIGH RISK" : "Safe"}
                </span>
                <span className="text-xs text-muted-foreground">{i + 1}h ago</span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}