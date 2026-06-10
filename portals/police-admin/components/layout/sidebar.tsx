"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";
import {
  Shield,
  LayoutDashboard,
  Phone,
  MessageSquare,
  ShieldAlert,
  FileText,
  Siren,
  Banknote,
  Network,
  Search,
  Users,
  Settings,
  LogOut,
  ChevronLeft,
  ChevronRight,
  BarChart3,
  Map,
  Fingerprint,
  Brain,
  BookOpen,
  AlertTriangle,
} from "lucide-react";
import { useState } from "react";

const menuItems = [
  { icon: LayoutDashboard, label: "Dashboard", href: "/" },
  { icon: AlertTriangle, label: "Live Monitoring", href: "/live-monitoring" },
  { icon: Phone, label: "Call Analysis", href: "/call-analysis" },
  { icon: MessageSquare, label: "SMS Analysis", href: "/sms-analysis" },
  { icon: ShieldAlert, label: "WhatsApp", href: "/whatsapp-analysis" },
  { icon: FileText, label: "Cases", href: "/cases" },
  { icon: FileText, label: "FIR Management", href: "/fir" },
  { icon: Siren, label: "Emergency SOS", href: "/emergency" },
  { icon: Banknote, label: "Bank Freeze", href: "/bank-freeze" },
  { icon: Network, label: "Fraud Network", href: "/fraud-network" },
  { icon: BarChart3, label: "Analytics", href: "/analytics" },
  { icon: Map, label: "Heatmap", href: "/heatmap" },
  { icon: Search, label: "Evidence Vault", href: "/evidence" },
  { icon: Fingerprint, label: "Deepfake", href: "/deepfake" },
  { icon: Brain, label: "Threat Intel", href: "/threat-intel" },
  { icon: BookOpen, label: "Reports", href: "/reports" },
  { icon: Users, label: "Users & Roles", href: "/users" },
  { icon: Settings, label: "Settings", href: "/settings" },
];

export function Sidebar() {
  const pathname = usePathname();
  const [collapsed, setCollapsed] = useState(false);

  return (
    <aside
      className={cn(
        "flex flex-col border-r border-border/50 bg-card/80 backdrop-blur-xl transition-all duration-300",
        collapsed ? "w-[68px]" : "w-64"
      )}
    >
      {/* Logo */}
      <div className="flex h-14 items-center border-b border-border/50 px-4">
        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-gradient-to-br from-primary to-cyan shadow-cyber shrink-0">
          <Shield className="h-4 w-4 text-white" />
        </div>
        {!collapsed && (
          <span className="ml-3 font-bold text-lg gradient-text truncate">CyberShield</span>
        )}
        <button
          onClick={() => setCollapsed(!collapsed)}
          className="ml-auto p-1.5 rounded-md hover:bg-accent transition-colors"
        >
          {collapsed ? (
            <ChevronRight className="h-4 w-4 text-muted-foreground" />
          ) : (
            <ChevronLeft className="h-4 w-4 text-muted-foreground" />
          )}
        </button>
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto p-2 space-y-0.5">
        {menuItems.map((item) => {
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all duration-200",
                isActive
                  ? "bg-primary/10 text-primary border border-primary/20 shadow-cyber"
                  : "text-muted-foreground hover:bg-accent/50 hover:text-foreground"
              )}
              title={collapsed ? item.label : undefined}
            >
              <item.icon className={cn("h-4 w-4 shrink-0", isActive && "text-primary")} />
              {!collapsed && <span className="truncate">{item.label}</span>}
              {!collapsed && item.label === "Emergency SOS" && (
                <span className="ml-auto h-2 w-2 rounded-full bg-red-500 animate-pulse-slow" />
              )}
            </Link>
          );
        })}
      </nav>

      {/* Footer */}
      <div className="border-t border-border/50 p-2">
        <Link
          href="/logout"
          className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm text-muted-foreground hover:bg-destructive/10 hover:text-destructive transition-colors"
        >
          <LogOut className="h-4 w-4 shrink-0" />
          {!collapsed && <span>Logout</span>}
        </Link>
      </div>
    </aside>
  );
}