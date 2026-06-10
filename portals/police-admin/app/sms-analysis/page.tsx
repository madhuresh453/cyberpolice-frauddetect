"use client";

import { useState } from "react";
import { MessageSquare, Search, Shield, AlertTriangle, Link, CheckCircle, XCircle, Filter } from "lucide-react";
import { cn } from "@/lib/utils";

export default function SmsAnalysisPage() {
  const [searchQuery, setSearchQuery] = useState("");
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight flex items-center gap-3">
          <MessageSquare className="h-8 w-8 text-primary" />
          SMS Analysis
        </h1>
        <p className="text-muted-foreground mt-1">AI-powered SMS fraud detection and scam analysis</p>
      </div>
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <input
            type="text"
            placeholder="Search SMS by content, number, or keyword..."
            className="w-full pl-10 pr-4 py-2.5 rounded-lg border border-border bg-card text-sm focus:outline-none focus:ring-2 focus:ring-primary/50"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
        <button className="px-4 py-2.5 rounded-lg border border-border bg-card text-sm hover:bg-accent flex items-center gap-2">
          <Filter className="h-4 w-4" /> Filters
        </button>
      </div>
      <div className="grid gap-4 md:grid-cols-3">
        {["OTP Scam", "Bank Fraud", "Phishing"].map((type) => (
          <div key={type} className="stat-card text-center">
            <p className="text-2xl font-bold">{Math.floor(Math.random() * 10000)}</p>
            <p className="text-sm text-muted-foreground mt-1">{type} Messages</p>
          </div>
        ))}
      </div>
      <div className="stat-card">
        <h2 className="text-lg font-semibold mb-4">Recent SMS</h2>
        <div className="space-y-2">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className={cn("p-4 rounded-lg border", i % 3 === 0 ? "border-red-500/20 bg-red-500/5" : "border-border/50 bg-card/50")}>
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-medium">+91 {7000000000 + i}</span>
                <div className="flex items-center gap-2">
                  {i % 3 === 0 && <AlertTriangle className="h-4 w-4 text-red-400" />}
                  {i % 3 === 0 ? <XCircle className="h-4 w-4 text-red-400" /> : <CheckCircle className="h-4 w-4 text-emerald-400" />}
                </div>
              </div>
              <p className="text-sm text-muted-foreground">{["Your account has been blocked. Click here to unblock: bit.ly/fake", "Your OTP is 123456", "Congratulations! You won ₹5,00,000. Claim now!", "Dear customer, your KYC is expired. Update now.", "Your bank account will be frozen. Call 1800-FAKE.", "Your OTP for transaction is 999999. Do not share.", "You have won a free iPhone! Click to claim.", "Urgent: Your account needs verification immediately."][i]}</p>
              <div className="flex items-center gap-2 mt-2">
                <span className={cn("text-xs px-2 py-0.5 rounded-full", i % 3 === 0 ? "bg-red-500/10 text-red-400" : "bg-emerald-500/10 text-emerald-400")}>
                  {i % 3 === 0 ? "FRAUD" : "Safe"}
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