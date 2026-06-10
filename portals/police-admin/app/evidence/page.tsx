"use client";

import React from "react";
import { Search, Upload, Shield, FileText, Image, Video, CheckCircle, Filter } from "lucide-react";
import { cn } from "@/lib/utils";

export default function EvidencePage() {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight flex items-center gap-3">
            <Shield className="h-8 w-8 text-primary" />
            Evidence Vault
          </h1>
          <p className="text-muted-foreground mt-1">Secure evidence management with chain of custody</p>
        </div>
        <button className="cyber-button flex items-center gap-2"><Upload className="h-4 w-4" /> Upload Evidence</button>
      </div>
      <div className="grid gap-4 md:grid-cols-4">
        {[
          { label: "Total Evidence", value: "2,847", icon: Shield },
          { label: "Audio Files", value: "1,230", icon: FileText },
          { label: "Screenshots", value: "890", icon: Image },
          { label: "Videos", value: "456", icon: Video },
        ].map((s) => (
          <div key={s.label} className="stat-card">
            <div className="flex items-center justify-between">
              <p className="text-sm text-muted-foreground">{s.label}</p>
              <s.icon className="h-4 w-4 text-primary" />
            </div>
            <p className="text-2xl font-bold mt-1">{s.value}</p>
          </div>
        ))}
      </div>
      <div className="stat-card">
        <h2 className="text-lg font-semibold mb-4">Evidence Items</h2>
        <div className="space-y-2">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className="flex items-center gap-4 p-3 rounded-lg border border-border/50 bg-card/50 hover:bg-accent/30 transition-colors">
              {[FileText, Image, Video, FileText][i % 4] ? (React.createElement([FileText, Image, Video, FileText][i % 4], { className: "h-5 w-5 text-muted-foreground shrink-0" })) : null}
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium">Evidence-{1000 + i}.{"wav,jpg,mp4,doc"[i % 4]}</p>
                <p className="text-xs text-muted-foreground">Case CS-2024-{1200 + i} — Hash: sha256:{i}a3b...c9d</p>
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle className="h-4 w-4 text-emerald-400" />
                <span className="text-xs text-emerald-400">Verified</span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}