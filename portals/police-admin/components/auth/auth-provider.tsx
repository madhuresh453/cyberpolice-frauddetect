"use client";

import { createContext, useContext, useState, useEffect, ReactNode } from "react";

const API = process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api/v1";

interface User {
  id: string;
  name: string;
  email: string;
  role: string;
  permissions: string[];
  avatar?: string;
}

interface AuthContextType {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  getAuthHeaders: () => Record<string, string>;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  token: null,
  isLoading: true,
  isAuthenticated: false,
  login: async () => {},
  logout: () => {},
  getAuthHeaders: () => ({ "Content-Type": "application/json" }),
});

export function useAuth() {
  return useContext(AuthContext);
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const storedToken = localStorage.getItem("jwt_token");
    const storedUser = localStorage.getItem("cybershield_user");
    if (storedToken && storedUser) {
      setToken(storedToken);
      setUser(JSON.parse(storedUser));
    }
    setIsLoading(false);
  }, []);

  const login = async (email: string, password: string) => {
    const res = await fetch(`${API}/auth/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password }),
    });
    const data = await res.json();
    if (!res.ok || !data.accessToken) {
      throw new Error(data.detail || data.message || "Login failed");
    }
    const accessToken = data.accessToken;
    const userProfile = data.user || {};
    const newUser: User = {
      id: userProfile.id || userProfile._id || "unknown",
      name: userProfile.fullName || userProfile.full_name || email.split("@")[0],
      email: userProfile.email || email,
      role: userProfile.role || userProfile.userType || "police",
      permissions: ["VIEW_CASES", "MANAGE_CASES", "VIEW_REPORTS", "MANAGE_USERS", "FREEZE_ACCOUNTS"],
    };
    setToken(accessToken);
    setUser(newUser);
    localStorage.setItem("jwt_token", accessToken);
    localStorage.setItem("refresh_token", data.refreshToken || "");
    localStorage.setItem("cybershield_user", JSON.stringify(newUser));
  };

  const logout = () => {
    setUser(null);
    setToken(null);
    localStorage.removeItem("jwt_token");
    localStorage.removeItem("refresh_token");
    localStorage.removeItem("cybershield_user");
  };

  const getAuthHeaders = () => ({
    "Content-Type": "application/json",
    Authorization: `Bearer ${token || localStorage.getItem("jwt_token") || ""}`,
  });

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isLoading,
        isAuthenticated: !!user && !!token,
        login,
        logout,
        getAuthHeaders,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}