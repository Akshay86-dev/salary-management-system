import React, { createContext, useState, useContext, useEffect, ReactNode } from 'react';
import authService, { AuthUser, AuthProfileResponse } from '../services/authService';

interface AuthContextType {
  user: AuthUser | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

const userFromProfile = (profile: AuthProfileResponse): AuthUser | null => {
  if (profile.data) {
    const { id, attributes } = profile.data;
    if (attributes.email && attributes.first_name && attributes.last_name) {
      return {
        id: Number(id),
        email: attributes.email,
        first_name: attributes.first_name,
        last_name: attributes.last_name,
      };
    }
  }

  return profile.user ?? null;
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);

  const isAuthenticated = !!user;

  // Check for existing session on mount
  useEffect(() => {
    const checkAuth = async () => {
      try {
        if (authService.isAuthenticated()) {
          const profile = await authService.getProfile();
          setUser(userFromProfile(profile));
        }
      } catch {
        localStorage.removeItem('token');
      } finally {
        setLoading(false);
      }
    };

    checkAuth();
  }, []);

  const login = async (email: string, password: string) => {
    const { user: authenticatedUser } = await authService.login(email, password);
    setUser(authenticatedUser);
  };

  const logout = async () => {
    await authService.logout();
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
