"use client";

import { useState } from "react";
import { Users, Search, Plus, Shield, UserCheck, UserX, Key } from "lucide-react";
import { cn } from "@/lib/utils";

export default function UsersPage() {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight flex items-center gap-3">
            <Users className="h-8 w-8 text-primary" />
            Users & Roles
          </h1>
          <p className="text-muted-foreground mt-1">Manage users, roles, permissions, and audit logs</p>
        </div>
        <button className="cyber-button flex items-center gap-2"><Plus className="h-4 w-4" /> Add User</button>
      </div>
      <div className="grid gap-4 md:grid-cols-4">
        {[
          { label: "Total Users", value: "234", color: "blue", icon: Users },
          { label: "Active", value: "189", color: "emerald", icon: UserCheck },
          { label: "Suspended", value: "12", color: "red", icon: UserX },
          { label: "Roles Defined", value: "8", color: "purple", icon: Key },
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
        <h2 className="text-lg font-semibold mb-4">Users</h2>
        <div className="space-y-2">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className="flex items-center gap-4 p-3 rounded-lg border border-border/50 bg-card/50 hover:bg-accent/30 transition-colors">
              <div className="h-10 w-10 rounded-full bg-gradient-to-br from-primary to-cyan flex items-center justify-center text-white text-sm font-bold shrink-0">
                {["PS", "DK", "AK", "MK", "RS", "AP", "SD", "VK"][i]}
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <span className="text-sm font-medium">{["Priya Singh", "Deepak Kumar", "Anjali Kapoor", "Manoj Kumar", "Ravi Sharma", "Arun Patel", "Sunita Devi", "Vikram Kumar"][i]}</span>
                  <span className={cn("text-xs px-2 py-0.5 rounded-full",
                    i < 5 ? "bg-emerald-500/10 text-emerald-400" : "bg-amber-500/10 text-amber-400"
                  )}>
                    {i < 5 ? "Active" : "Inactive"}
                  </span>
                </div>
                <p className="text-xs text-muted-foreground">{["Inspector", "Sub-Inspector", "Constable", "Head Constable", "DCP", "ACP", "SI", "Constable"][i]} — {["Mumbai", "Delhi", "Bangalore", "Chennai", "Pune", "Hyderabad", "Kolkata", "Jaipur"][i]}</p>
              </div>
              <button className="text-xs text-primary hover:underline">Edit</button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}