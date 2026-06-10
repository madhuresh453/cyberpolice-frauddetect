"use client";

import { useState } from "react";
import { Fingerprint, Upload, Brain, AlertTriangle, CheckCircle, FileText } from "lucide-react";
import { cn } from "@/lib/utils";

export default function DeepfakePage() {
  const [analysisResult, setAnalysisResult] = useState<any>(null);
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight flex items-center gap-3">
          <Fingerprint className="h-8 w-8 text-purple-500" />
          Deepfake Detection
        </h1>
        <p className="text-muted-foreground mt-1">AI-powered voice and video deepfake analysis</p>
      </div>
      <div className="grid gap-4 md:grid-cols-3">
        {[
          { label: "Total Analyzed", value: "1,456", color: "purple" },
          { label: "Deepfakes Found", value: "89", color: "red" },
          { label: "Accuracy Rate", value: "96.7%", color: "emerald" },
        ].map((s) => (
          <div key={s.label} className="stat-card">
            <p className="text-sm text-muted-foreground">{s.label}</p>
            <p className={cn("text-2xl font-bold mt-1", `text-${s.color}-500`)}>{s.value}</p>
          </div>
        ))}
      </div>
      <div className="stat-card">
        <h2 className="text-lg font-semibold mb-4">Upload for Analysis</h2>
        <div className="border-2 border-dashed border-border rounded-xl p-8 text-center hover:border-primary/50 transition-colors cursor-pointer">
          <Upload className="h-12 w-12 text-muted-foreground mx-auto mb-3" />
          <p className="text-muted-foreground">Drag & drop audio or video file here</p>
          <p className="text-xs text-muted-foreground mt-1">Supports WAV, MP3, MP4, WebM</p>
        </div>
      </div>
      <div className="stat-card">
        <h2 className="text-lg font-semibold mb-4">Recent Analyses</h2>
        <div className="space-y-2">
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className={cn("flex items-center gap-4 p-3 rounded-lg border", i % 3 === 0 ? "border-red-500/20 bg-red-500/5" : "border-border/50 bg-card/50")}>
              <Fingerprint className="h-5 w-5 shrink-0" style={{ color: i % 3 === 0 ? "rgb(239 68 68)" : "rgb(16 185 129)" }} />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <span className="text-sm font-medium">DF-{2000 + i}</span>
                  {i % 3 === 0 ? <AlertTriangle className="h-3 w-3 text-red-400" /> : <CheckCircle className="h-3 w-3 text-emerald-400" />}
                </div>
                <p className="text-xs text-muted-foreground">Score: {i % 3 === 0 ? "87" : "12"}/100 — {i % 3 === 0 ? "DEEPFAKE" : "Authentic"}</p>
              </div>
              <span className={cn("text-xs px-2 py-0.5 rounded-full", i % 3 === 0 ? "bg-red-500/10 text-red-400" : "bg-emerald-500/10 text-emerald-400")}>
                {i % 3 === 0 ? "DETECTED" : "CLEAR"}
              </span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}