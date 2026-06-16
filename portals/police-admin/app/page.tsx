"use client";

import { useEffect } from "react";

export default function HomePage() {
  useEffect(() => {
    const token = localStorage.getItem("jwt_token");
    if (token) {
      window.location.href = "/dashboard";
    } else {
      window.location.href = "/login";
    }
  }, []);

  return (
    <div className="min-h-screen bg-background flex items-center justify-center">
      <div className="text-center">
        <div className="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-4" />
        <p className="text-muted-foreground">Redirecting to RAKSAAR Portal...</p>
      </div>
    </div>
  );
}