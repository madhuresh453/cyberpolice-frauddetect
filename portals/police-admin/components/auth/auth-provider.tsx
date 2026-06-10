"use client";

import { createContext, useContext, useState, useEffect, ReactNode } from "react";

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
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  token: null,
  isLoading: true,
  isAuthenticated: false,
  login: async () => {},
  logout: () => {},
});

export function useAuth() {
  return useContext(AuthContext);
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const storedToken = localStorage.getItem("cybershield_token");
    const storedUser = localStorage.getItem("cybershield_user");
    if (storedToken && storedUser) {
      setToken(storedToken);
      setUser(JSON.parse(storedUser));
    }
    setIsLoading(false);
  }, []);

  const login = async (email: string, password: string) => {
    const mockUser: User = {
      id: "1",
      name: "Police Admin",
      email,
      role: "admin",
      permissions: ["VIEW_CASES", "MANAGE_CASES", "VIEW_REPORTS", "MANAGE_USERS", "FREEZE_ACCOUNTS"],
    };
    const mockToken = "mock_jwt_token_" + Date.now();
    setUser(mockUser);
    setToken(mockToken);
    localStorage.setItem("cybershield_token", mockToken);
    localStorage.setItem("cybershield_user", JSON.stringify(mockUser));
  };

  const logout = () => {
    setUser(null);
    setToken(null);
    localStorage.removeItem("cybershield_token");
    localStorage.removeItem("cybershield_user");
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isLoading,
        isAuthenticated: !!user && !!token,
        login,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}