"use client";

import { Map, MapPin, Layers, Filter } from "lucide-react";
import { cn } from "@/lib/utils";

export default function HeatmapPage() {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight flex items-center gap-3">
            <Map className="h-8 w-8 text-primary" />
            National Fraud Heatmap
          </h1>
          <p className="text-muted-foreground mt-1">Geographic distribution of fraud incidents across India</p>
        </div>
        <div className="flex gap-2">
          <button className="px-3 py-2 rounded-lg border border-border bg-card text-sm hover:bg-accent flex items-center gap-2">
            <Layers className="h-4 w-4" /> Layers
          </button>
          <button className="px-3 py-2 rounded-lg border border-border bg-card text-sm hover:bg-accent flex items-center gap-2">
            <Filter className="h-4 w-4" /> Filter
          </button>
        </div>
      </div>
      <div className="grid gap-4 md:grid-cols-4">
        {[
          { label: "Total Hotspots", value: "2,340", color: "red" },
          { label: "Active Regions", value: "28", color: "blue" },
          { label: "Top State", value: "Maharashtra", color: "amber" },
          { label: "Top City", value: "Mumbai", color: "purple" },
        ].map((s) => (
          <div key={s.label} className="stat-card">
            <p className="text-sm text-muted-foreground">{s.label}</p>
            <p className={cn("text-xl font-bold mt-1", `text-${s.color}-500`)}>{s.value}</p>
          </div>
        ))}
      </div>
      <div className="stat-card min-h-[500px] flex items-center justify-center">
        <div className="text-center">
          <Map className="h-16 w-16 text-muted-foreground/30 mx-auto mb-4" />
          <p className="text-muted-foreground">Mapbox integration will display the live fraud heatmap</p>
          <p className="text-xs text-muted-foreground mt-2">District-level view of fraud density across India</p>
        </div>
      </div>
    </div>
  );
}