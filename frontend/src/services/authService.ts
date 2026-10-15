import apiClient from './api';

export interface AuthUser {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
}

export interface AuthProfileResponse {
  data?: {
    id: number | string;
    attributes: Partial<AuthUser>;
  };
  user?: AuthUser;
}

interface SignInResponse {
  data?: {
    id: number | string;
    attributes?: Partial<AuthUser>;
    token?: string;
  };
  user?: AuthUser;
}

// Authentication service for login, logout, and registration
const authService = {
  // Login with email and password
  login: async (email: string, password: string): Promise<{ user: AuthUser | null; token: string | null }> => {
    const response = await apiClient.post('/users/sign_in', {
      user: { email, password },
    });
    // Devise JWT returns token in Authorization header
    const authHeader = response.headers.authorization || response.headers.Authorization;
    const body: SignInResponse = response.data;
    const token = authHeader
      ? authHeader.replace('Bearer ', '')
      : body.data?.token || null;
    if (token) {
      localStorage.setItem('token', token);
    }
    const attributes = body.data?.attributes;
    const user = attributes?.email && attributes.first_name && attributes.last_name
      ? {
          id: Number(body.data?.id),
          email: attributes.email,
          first_name: attributes.first_name,
          last_name: attributes.last_name,
        }
      : body.user ?? null;
    return { user, token };
  },

  // Logout current user
  logout: async () => {
    await apiClient.delete('/users/sign_out');
    localStorage.removeItem('token');
  },

  // Register a new user
  register: async (userData: Partial<AuthUser>) => {
    const response = await apiClient.post('/users', {
      user: userData,
    });
    return response.data.user;
  },

  // Get current user profile
  getProfile: async (): Promise<AuthProfileResponse> => {
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