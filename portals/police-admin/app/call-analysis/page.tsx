"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Phone, Search, Play, Pause, Download, Filter, AlertTriangle, CheckCircle, Brain, FileText, TrendingUp } from "lucide-react";
import { cn } from "@/lib/utils";

export default function CallAnalysisPage() {
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCall, setSelectedCall] = useState<any>(null);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight flex items-center gap-3">
          <Phone className="h-8 w-8 text-primary" />
          Call Analysis
        </h1>
        <p className="text-muted-foreground mt-1">AI-powered voice analysis and fraud detection</p>
      </div>

      {/* Search & Filters */}
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <input
            type="text"
            placeholder="Search by phone number, transcript, or keyword..."
            className="w-full pl-10 pr-4 py-2.5 rounded-lg border border-border bg-card text-sm focus:outline-none focus:ring-2 focus:ring-primary/50"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
        <button className="px-4 py-2.5 rounded-lg border border-border bg-card text-sm hover:bg-accent flex items-center gap-2">
          <Filter className="h-4 w-4" /> Filters
        </button>
      </div>

      {/* Call List */}
      <div className="grid gap-6 lg:grid-cols-5">
        <div className="lg:col-span-2 space-y-2">
          <h3 className="text-sm font-medium text-muted-foreground mb-2">Recent Calls</h3>
          {Array.from({ length: 10 }).map((_, i) => (
            <div
              key={i}
              onClick={() => setSelectedCall({ id: i })}
              className={cn(
                "p-3 rounded-lg border cursor-pointer transition-all",
                selectedCall?.id === i
                  ? "border-primary/30 bg-primary/5 shadow-cyber"
                  : "border-border/50 bg-card/50 hover:bg-accent/30"
              )}
            >
              <div className="flex items-center justify-between">
                <span className="text-sm font-medium">+91 {7000000000 + i}</span>
                <span className={cn("text-xs px-2 py-0.5 rounded-full",
                  i % 4 === 0 ? "bg-red-500/10 text-red-400" : "bg-emerald-500/10 text-emerald-400"
                )}>
                  {i % 4 === 0 ? "HIGH RISK" : "Safe"}
                </span>
              </div>
              <div className="flex items-center gap-2 mt-1 text-xs text-muted-foreground">
                <span>{Math.floor(Math.random() * 300)}s</span>
                <span>•</span>
                <span>{["Outgoing", "Incoming"][i % 2]}</span>
                <span>•</span>
                <span>{i + 1}h ago</span>
              </div>
            </div>
          ))}
        </div>

        {/* Call Detail */}
        <div className="lg:col-span-3 space-y-4">
          {selectedCall ? (
            <>
              {/* Transcript */}
              <div className="stat-card">
                <h3 className="font-semibold mb-3 flex items-center gap-2">
                  <FileText className="h-4 w-4" /> Transcript
                </h3>
                <div className="bg-muted/30 rounded-lg p-4 font-mono text-sm space-y-2 max-h-[200px] overflow-y-auto">
                  <p><span className="text-blue-400">Caller:</span> Hello, I am calling from your bank. Your account will be blocked.</p>
                  <p><span className="text-emerald-400">Victim:</span> Really? What should I do?</p>
                  <p><span className="text-blue-400">Caller:</span> You need to share your OTP immediately.</p>
                  <p className="text-red-400"><span className="text-red-400">AI Alert:</span> ⚠️ Fraud pattern detected: "OTP request" keyword</p>
                </div>
              </div>

              {/* AI Analysis */}
              <div className="stat-card">
                <h3 className="font-semibold mb-3 flex items-center gap-2">
                  <Brain className="h-4 w-4 text-purple-400" /> AI Analysis
                </h3>
                <div className="grid grid-cols-2 gap-3">
                  {[
                    { label: "Fraud Probability", value: "94%", color: "red" },
                    { label: "Sentiment", value: "Threatening", color: "amber" },
                    { label: "Keywords", value: "OTP, Bank, Blocked", color: "blue" },
                    { label: "Voice Match", value: "Known Scammer #1247", color: "purple" },
                  ].map((item) => (
                    <div key={item.label} className="p-3 rounded-lg bg-muted/30">
                      <p className="text-xs text-muted-foreground">{item.label}</p>
                      <p className={cn("text-sm font-bold mt-1", `text-${item.color}-400`)}>{item.value}</p>
                    </div>
                  ))}
                </div>
              </div>
            </>
          ) : (
            <div className="stat-card flex items-center justify-center h-[400px] text-muted-foreground">
              <p>Select a call to view analysis</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}