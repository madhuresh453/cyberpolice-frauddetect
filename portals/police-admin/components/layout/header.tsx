"use client";

import { Bell, Moon, Sun, Menu } from "lucide-react";
import { useTheme } from "next-themes";
import { useState, useEffect } from "react";

export function Header() {
  const { theme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  useEffect(() => setMounted(true), []);

  return (
    <header className="flex h-14 items-center justify-between border-b bg-card px-4 md:px-6">
      <div className="flex items-center gap-4">
        <h2 className="hidden md:block text-sm font-medium text-muted-foreground">
          CyberShield AI — Police Command Center
        </h2>
      </div>
      <div className="flex items-center gap-2">
        <button
          onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
          className="p-2 rounded-md hover:bg-accent"
          aria-label="Toggle theme"
        >
          {mounted ? (theme === "dark" ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />) : <Sun className="h-4 w-4" />}
        </button>
        <button className="relative p-2 rounded-md hover:bg-accent" aria-label="Notifications">
          <Bell className="h-4 w-4" />
          <span className="absolute top-1 right-1 h-2 w-2 rounded-full bg-red-500" />
        </button>
        <div className="hidden md:flex items-center gap-2 ml-2 pl-2 border-l">
          <div className="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center text-xs font-bold text-primary">
            PS
          </div>
          <span className="text-sm font-medium">Police Admin</span>
        </div>
      </div>
    </header>
  );
}