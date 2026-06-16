"use client";

import { Inter } from "next/font/google";
import { ThemeProvider } from "next-themes";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "sonner";
import { Sidebar } from "@/components/layout/sidebar";
import { Header } from "@/components/layout/header";
import { AuthProvider } from "@/components/auth/auth-provider";
import { usePathname } from "next/navigation";
import { useState } from "react";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export default function RootLayout({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(() => new QueryClient());
  const pathname = usePathname();
  const isLoginPage = pathname === "/login";

  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <QueryClientProvider client={queryClient}>
          <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
            <AuthProvider>
              {isLoginPage ? (
                <div className="min-h-screen bg-background">{children}</div>
              ) : (
                <div className="flex h-screen overflow-hidden bg-background">
                  <Sidebar />
                  <div className="flex flex-1 flex-col overflow-hidden">
                    <Header />
                    <main className="flex-1 overflow-y-auto p-4 md:p-6">{children}</main>
                  </div>
                </div>
              )}
            </AuthProvider>
            <Toaster position="top-right" richColors />
          </ThemeProvider>
        </QueryClientProvider>
      </body>
    </html>
  );
}
