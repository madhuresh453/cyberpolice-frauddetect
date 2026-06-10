"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Banknote, Search, Plus, CheckCircle, XCircle, Clock, AlertTriangle, Building2 } from "lucide-react";
import { cn } from "@/lib/utils";

export default function BankFreezePage() {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight flex items-center gap-3">
            <Banknote className="h-8 w-8 text-primary" />
            Bank Account Freeze
          </h1>
          <p className="text-muted-foreground mt-1">Freeze suspicious bank accounts and UPI IDs</p>
        </div>
        <button className="cyber-button flex items-center gap-2"><Plus className="h-4 w-4" /> New Freeze Request</button>
      </div>
      <div className="grid gap-4 md:grid-cols-4">
        {[
          { label: "Pending", value: "23", color: "amber", icon: Clock },
          { label: "Approved", value: "67", color: "emerald", icon: CheckCircle },
          { label: "Rejected", value: "8", color: "red", icon: XCircle },
          { label: "Total Amount Frozen", value: "₹4.2Cr", color: "blue", icon: Banknote },
        ].map((s) => (
          <div key={s.label} className="stat-card">
            <div className="flex items-center justify-between">
              <p className="text-sm text-muted-foreground">{s.label}</p>
              <s.icon className={cn("h-4 w-4", `text-${s.color}-500`)} />
            </div>
            <p className={cn("text-2xl font-bold mt-1", `text-${s.color}-500`)}>{s.value}</p>
          </div>
        ))}
      </div>
      <div className="stat-card">
        <h2 className="text-lg font-semibold mb-4">Freeze Requests</h2>
        <div className="space-y-2">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className="flex items-center gap-4 p-4 rounded-lg border border-border/50 bg-card/50 hover:bg-accent/30 transition-colors">
              <Building2 className="h-5 w-5 text-muted-foreground shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 flex-wrap">
                  <span className="text-sm font-medium">ACC-{100000 + i}</span>
                  <span className={cn("text-xs px-2 py-0.5 rounded-full",
                    i % 3 === 0 ? "bg-amber-500/10 text-amber-400" : i % 3 === 1 ? "bg-emerald-500/10 text-emerald-400" : "bg-red-500/10 text-red-400"
                  )}>
                    {["Pending", "Approved", "Rejected"][i % 3]}
                  </span>
                </div>
                <p className="text-xs text-muted-foreground mt-0.5">{["SBI", "HDFC", "ICICI", "AXIS", "PNB"][i % 5]} — ₹{(50000 + i * 120000).toLocaleString("en-IN")}</p>
              </div>
              <div className="flex gap-2">
                {i % 3 === 0 && (
                  <>
                    <button className="px-3 py-1.5 rounded-md bg-emerald-500/10 text-emerald-400 text-xs font-medium">Approve</button>
                    <button className="px-3 py-1.5 rounded-md bg-red-500/10 text-red-400 text-xs font-medium">Reject</button>
                  </>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}