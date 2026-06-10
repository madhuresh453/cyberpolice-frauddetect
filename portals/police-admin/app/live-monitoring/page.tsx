"use client";

import { useState, useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { AlertTriangle, Phone, MessageSquare, Shield, Radio, Activity, Clock, TrendingUp, Zap, Circle } from "lucide-react";
import { cn } from "@/lib/utils";

export default function LiveMonitoringPage() {
  const [wsConnected, setWsConnected] = useState(false);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight flex items-center gap-3">
            <Radio className="h-8 w-8 text-red-500 animate-pulse-slow" />
            Live Monitoring
          </h1>
          <p className="text-muted-foreground mt-1">Real-time threat intelligence across all channels</p>
        </div>
        <div className="flex items-center gap-3">
          <div className={cn("flex items-center gap-2 px-3 py-1.5 rounded-full text-xs font-medium",
            wsConnected ? "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20" : "bg-red-500/10 text-red-400 border border-red-500/20"
          )}>
            <Circle className={cn("h-2 w-2 fill-current", wsConnected ? "animate-pulse-slow" : "")} />
            {wsConnected ? "Connected" : "Disconnected"}
          </div>
        </div>
      </div>

      {/* Live Stats */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {[
          { label: "Active Calls", value: "2,847", icon: Phone, color: "blue", trend: "+12%" },
          { label: "Live Alerts", value: "156", icon: AlertTriangle, color: "red", trend: "+8%" },
          { label: "SMS Monitored", value: "18,432", icon: MessageSquare, color: "green", trend: "+5%" },
          { label: "AI Detections", value: "89", icon: Shield, color: "purple", trend: "+23%" },
        ].map((stat) => (
          <div key={stat.label} className="stat-card group">
            <div className="flex items-center justify-between">
              <p className="text-sm text-muted-foreground">{stat.label}</p>
              <stat.icon className={cn("h-4 w-4", `text-${stat.color}-500`)} />
            </div>
            <div className="mt-3 flex items-end justify-between">
              <p className="text-2xl font-bold">{stat.value}</p>
              <span className="text-xs text-emerald-400 flex items-center gap-1">
                <TrendingUp className="h-3 w-3" />{stat.trend}
              </span>
            </div>
          </div>
        ))}
      </div>

      {/* Live Feed */}
      <div className="grid gap-6 lg:grid-cols-2">
        <div className="stat-card">
          <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <Activity className="h-5 w-5 text-primary" /> Live Call Feed
          </h2>
          <div className="space-y-3 max-h-[400px] overflow-y-auto">
            {Array.from({ length: 8 }).map((_, i) => (
              <div key={i} className="flex items-center gap-3 p-3 rounded-lg border border-border/50 bg-card/50 hover:bg-accent/30 transition-colors">
                <div className={cn("h-2 w-2 rounded-full", i % 3 === 0 ? "bg-red-500 animate-pulse-slow" : "bg-emerald-500")} />
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-medium">+91 {7000000000 + i}</span>
                    <span className={cn("text-xs px-2 py-0.5 rounded-full", i % 3 === 0 ? "bg-red-500/10 text-red-400" : "bg-emerald-500/10 text-emerald-400")}>
                      {i % 3 === 0 ? "HIGH RISK" : "Normal"}
                    </span>
                  </div>
                  <p className="text-xs text-muted-foreground mt-0.5">Duration: {Math.floor(Math.random() * 300)}s</p>
                </div>
                <span className="text-xs text-muted-foreground">{i}m ago</span>
              </div>
            ))}
          </div>
        </div>

        <div className="stat-card">
          <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <AlertTriangle className="h-5 w-5 text-destructive" /> Threat Timeline
          </h2>
          <div className="space-y-3 max-h-[400px] overflow-y-auto">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className={cn("p-3 rounded-lg border", i % 2 === 0 ? "border-red-500/20 bg-red-500/5" : "border-border/50 bg-card/50")}>
                <div className="flex items-center gap-2 mb-1">
                  <Zap className={cn("h-3 w-3", i % 2 === 0 ? "text-red-400" : "text-amber-400")} />
                  <span className="text-sm font-medium">{["Fraud Call Detected", "Suspicious SMS", "Deepfake Alert", "UPI Fraud Attempt", "Phishing Link", "Account Takeover"][i]}</span>
                </div>
                <p className="text-xs text-muted-foreground">Detected in region — automatic response initiated</p>
                <span className="text-xs text-muted-foreground mt-1 block">{i + 1}m ago</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Fraud Keyword Detection */}
      <div className="stat-card">
        <h2 className="text-lg font-semibold mb-4">AI Fraud Keyword Detection</h2>
        <div className="grid gap-3 md:grid-cols-3 lg:grid-cols-6">
          {["KYC", "OTP", "Urgent Transfer", "Account Blocked", "KYC Expired", "Win Prize"].map((kw) => (
            <div key={kw} className="p-3 rounded-lg border border-border/50 bg-card/50 text-center">
              <p className="text-sm font-medium text-amber-400">{kw}</p>
              <p className="text-lg font-bold mt-1">{Math.floor(Math.random() * 500)}</p>
              <p className="text-xs text-muted-foreground">detections</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}