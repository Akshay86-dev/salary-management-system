import apiClient from './api';

// Authentication service for login, logout, and registration
const authService = {
  // Login with email and password
  login: async (email, password) => {
    const response = await apiClient.post('/users/sign_in', {
      user: { email, password },
    });
    // Devise JWT returns token in Authorization header
    const authHeader = response.headers.authorization || response.headers.Authorization;
    const token = authHeader ? authHeader.replace('Bearer ', '') : null;
    if (token) {
      localStorage.setItem('token', token);
    }
    return { user: response.data.user, token };
  },

  // Logout current user
  logout: async () => {
    await apiClient.delete('/users/sign_out');
    localStorage.removeItem('token');
  },

  // Register a new user
  register: async (userData) => {
    const response = await apiClient.post('/users', {
      user: userData,
    });
    return response.data.user;
  },

  // Get current user profile
  getProfile: async () => {
    const response = await apiClient.get('/auth/profile');
    return response.data;
  },

  // Check if user is authenticated (has valid token)
  isAuthenticated: () => {
    const token = localStorage.getItem('token');
    return !!token;
  },

  // Get current token
  getToken: () => {
    return localStorage.getItem('token');
  },
};

export default authService;