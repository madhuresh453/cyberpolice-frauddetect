"use client";

import { useState } from "react";
import { Siren, MapPin, Clock, User, Phone, AlertTriangle, CheckCircle, Shield, Radio } from "lucide-react";
import { cn } from "@/lib/utils";

export default function EmergencyPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight flex items-center gap-3">
          <Siren className="h-8 w-8 text-red-500 animate-pulse-slow" />
          Emergency SOS
        </h1>
        <p className="text-muted-foreground mt-1">Real-time emergency response and citizen distress management</p>
      </div>
      <div className="grid gap-4 md:grid-cols-4">
        {[
          { label: "Active SOS", value: "5", color: "red", icon: Siren },
          { label: "Responding", value: "3", color: "amber", icon: Radio },
          { label: "Resolved Today", value: "18", color: "emerald", icon: CheckCircle },
          { label: "Avg Response", value: "42s", color: "blue", icon: Clock },
        ].map((s) => (
          <div key={s.label} className={cn("stat-card border-l-4", `border-l-${s.color}-500`)}>
            <div className="flex items-center justify-between">
              <p className="text-sm text-muted-foreground">{s.label}</p>
              <s.icon className={cn("h-4 w-4", `text-${s.color}-500`)} />
            </div>
            <p className={cn("text-2xl font-bold mt-1", `text-${s.color}-500`)}>{s.value}</p>
          </div>
        ))}
      </div>
      <div className="stat-card">
        <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
          <AlertTriangle className="h-5 w-5 text-red-400 animate-pulse-slow" /> Active SOS Sessions
        </h2>
        <div className="space-y-3">
          {Array.from({ length: 5 }).map((_, i) => (
            <div key={i} className={cn("p-4 rounded-lg border", i < 2 ? "border-red-500/30 bg-red-500/5" : "border-amber-500/20 bg-amber-500/5")}>
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <span className="text-sm font-medium">SOS-{String(Date.now() + i).slice(-8)}</span>
                  <span className={cn("text-xs px-2 py-0.5 rounded-full",
                    i < 2 ? "bg-red-500/20 text-red-400 animate-pulse-slow" : "bg-amber-500/20 text-amber-400"
                  )}>
                    {i < 2 ? "CRITICAL" : "RESPONDING"}
                  </span>
                </div>
                <span className="text-xs text-muted-foreground">{i + 1}m ago</span>
              </div>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 text-xs text-muted-foreground">
                <div className="flex items-center gap-1"><User className="h-3 w-3" /> Citizen #{1000 + i}</div>
                <div className="flex items-center gap-1"><MapPin className="h-3 w-3" /> Sector {12 + i * 3}</div>
                <div className="flex items-center gap-1"><Phone className="h-3 w-3" /> +91 7000{i}0000{i}</div>
                <div className="flex items-center gap-1"><Clock className="h-3 w-3" /> {i + 1}m elapsed</div>
              </div>
              <div className="flex gap-2 mt-3">
                <button className="px-3 py-1.5 rounded-md bg-red-500/10 text-red-400 text-xs font-medium hover:bg-red-500/20">Dispatch</button>
                <button className="px-3 py-1.5 rounded-md bg-primary/10 text-primary text-xs font-medium hover:bg-primary/20">View Details</button>
                <button className="px-3 py-1.5 rounded-md bg-emerald-500/10 text-emerald-400 text-xs font-medium hover:bg-emerald-500/20">Resolve</button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}