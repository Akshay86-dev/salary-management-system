import { useState, useEffect, useCallback } from 'react';
import authService from '../services/authService';

// Custom hook for authentication
const useAuth = () => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Check for existing session on mount
  useEffect(() => {
    const checkAuth = async () => {
      try {
        if (authService.isAuthenticated()) {
          const profile = await authService.getProfile();
          setUser(profile.data || profile.user || null);
        }
      } catch (err) {
        console.error('Auth check failed:', err);
        localStorage.removeItem('token');
      } finally {
        setLoading(false);
      }
    };

    checkAuth();
  }, []);

  // Login function
  const login = useCallback(async (email, password) => {
    setError(null);
    try {
      const { user } = await authService.login(email, password);
      setUser(user);
      return user;
    } catch (err) {
      setError(err.response?.data?.errors || err.message || 'Login failed');
      throw err;
    }
  }, []);

  // Logout function
  const logout = useCallback(async () => {
    setError(null);
    try {
      await authService.logout();
      setUser(null);
      window.location.href = '/login';
    } catch (err) {
      console.error('Logout failed:', err);
    }
  }, []);

  // Register function
  const register = useCallback(async (userData) => {
    setError(null);
    try {
      const newUser = await authService.register(userData);
      setUser(newUser);
      return newUser;
    } catch (err) {
      setError(err.response?.data?.errors || err.message || 'Registration failed');
      throw err;
    }
  }, []);

  // Refresh user profile
  const refreshProfile = useCallback(async () => {
    try {
      const profile = await authService.getProfile();
      setUser(profile.data || profile.user || null);
    } catch (err) {
      console.error('Profile refresh failed:', err);
    }
  }, []);

  return {
    user,
    loading,
    error,
    login,
    logout,
    register,
    refreshProfile,
    isAuthenticated: !!user,
  };
};

export default useAuth;