"use client";

import { useState } from "react";
import { Settings, Bell, Shield, Key, Globe, Save } from "lucide-react";
import { cn } from "@/lib/utils";

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState("general");
  const tabs = [
    { id: "general", label: "General", icon: Settings },
    { id: "alerts", label: "Alerts", icon: Bell },
    { id: "security", label: "Security", icon: Shield },
    { id: "api", label: "API", icon: Key },
    { id: "integrations", label: "Integrations", icon: Globe },
  ];
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight flex items-center gap-3">
          <Settings className="h-8 w-8 text-primary" />
          Settings
        </h1>
        <p className="text-muted-foreground mt-1">System configuration and preferences</p>
      </div>
      <div className="flex gap-2 p-1 rounded-lg border border-border bg-card w-fit">
        {tabs.map((t) => (
          <button
            key={t.id}
            onClick={() => setActiveTab(t.id)}
            className={cn("px-4 py-2 rounded-md text-sm font-medium transition-colors flex items-center gap-2",
              activeTab === t.id ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground"
            )}
          >
            <t.icon className="h-4 w-4" /> {t.label}
          </button>
        ))}
      </div>
      <div className="stat-card">
        <h2 className="text-lg font-semibold mb-4">System Configuration</h2>
        <div className="space-y-4 max-w-2xl">
          {[
            { label: "System Name", value: "CyberShield AI", type: "text" },
            { label: "Alert Email", value: "admin@cybershield.gov.in", type: "email" },
            { label: "API Rate Limit (req/min)", value: "1000", type: "number" },
            { label: "Session Timeout (min)", value: "30", type: "number" },
            { label: "Max Upload Size (MB)", value: "50", type: "number" },
          ].map((field) => (
            <div key={field.label}>
              <label className="text-sm font-medium text-muted-foreground">{field.label}</label>
              <input
                type={field.type}
                defaultValue={field.value}
                className="w-full mt-1 px-3 py-2 rounded-lg border border-border bg-card text-sm focus:outline-none focus:ring-2 focus:ring-primary/50"
              />
            </div>
          ))}
          <button className="cyber-button flex items-center gap-2"><Save className="h-4 w-4" /> Save Changes</button>
        </div>
      </div>
    </div>
  );
}