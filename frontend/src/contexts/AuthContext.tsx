import React, { createContext, useState, useContext, useEffect, ReactNode } from 'react';
import { authAPI } from '../services/api';

interface User {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
}

interface AuthContextType {
  user: User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  const isAuthenticated = !!user;

  // Check for existing session on mount
  useEffect(() => {
    const checkAuth = async () => {
      const token = localStorage.getItem('token');
      if (token) {
        try {
          const profile = await authAPI.getProfile();
          if (profile.data) {
            setUser({
              id: profile.data.data.attributes.id,
              email: profile.data.data.attributes.email,
              first_name: profile.data.data.attributes.first_name,
              last_name: profile.data.data.attributes.last_name,
            });
          }
        } catch (error) {
          localStorage.removeItem('token');
        }
      }
      setLoading(false);
    };

    checkAuth();
  }, []);

  const login = async (email: string, password: string) => {
    const response = await authAPI.login(email, password);
    const token = response.token;
    if (token) {
      localStorage.setItem('token', token);
    }
    const profile = await authAPI.getProfile();
    if (profile.data) {
      setUser({
        id: profile.data.data.attributes.id,
        email: profile.data.data.attributes.email,
        first_name: profile.data.data.attributes.first_name,
        last_name: profile.data.data.attributes.last_name,
      });
    }
  };

  const logout = async () => {
    await authAPI.logout();
    localStorage.removeItem('token');
    setUser(null);
    window.location.href = '/login';
  };

  const value = {
    user,
    loading,
    login,
    logout,
    isAuthenticated,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};
