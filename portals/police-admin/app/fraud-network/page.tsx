"use client";

import { useState } from "react";
import { Network, Search, Maximize2, RefreshCw, Filter } from "lucide-react";
import { cn } from "@/lib/utils";

export default function FraudNetworkPage() {
  const [searchPhone, setSearchPhone] = useState("");
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight flex items-center gap-3">
          <Network className="h-8 w-8 text-primary" />
          Fraud Network Graph
        </h1>
        <p className="text-muted-foreground mt-1">Neo4j-powered fraud ring detection and network analysis</p>
      </div>
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <input
            type="text"
            placeholder="Enter phone number, UPI ID, or device ID..."
            className="w-full pl-10 pr-4 py-2.5 rounded-lg border border-border bg-card text-sm focus:outline-none focus:ring-2 focus:ring-primary/50"
            value={searchPhone}
            onChange={(e) => setSearchPhone(e.target.value)}
          />
        </div>
        <button className="cyber-button">Analyze Network</button>
      </div>
      <div className="grid gap-4 md:grid-cols-3">
        <div className="stat-card"><p className="text-sm text-muted-foreground">Fraud Rings Detected</p><p className="text-2xl font-bold text-red-400 mt-1">12</p></div>
        <div className="stat-card"><p className="text-sm text-muted-foreground">Connected Numbers</p><p className="text-2xl font-bold text-amber-400 mt-1">1,847</p></div>
        <div className="stat-card"><p className="text-sm text-muted-foreground">Shared Devices</p><p className="text-2xl font-bold text-purple-400 mt-1">234</p></div>
      </div>
      <div className="stat-card min-h-[500px] flex items-center justify-center">
        <div className="text-center">
          <Network className="h-16 w-16 text-muted-foreground/30 mx-auto mb-4" />
          <p className="text-muted-foreground">Search for a phone number to visualize the fraud network graph</p>
          <p className="text-xs text-muted-foreground mt-2">Powered by Neo4j Graph Database</p>
        </div>
      </div>
    </div>
  );
}