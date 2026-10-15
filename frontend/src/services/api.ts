import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';

// Create axios instance with base configuration
// In development, Vite dev server proxies API requests to Rails on port 3000
// In production, Rails serves the React frontend from the same origin
const apiClient: AxiosInstance = axios.create({
  baseURL: '/api/v1',
  // Important: credentials must be true for cookie-based JWT auth
  // Or use Authorization header with Bearer token
  withCredentials: false, // We use JWT in Authorization header
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Request interceptor to add JWT token to Authorization header
apiClient.interceptors.request.use(
  (config: AxiosRequestConfig): AxiosRequestConfig => {
    const token = localStorage.getItem('token');
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  },
);

// Response interceptor to handle auth errors
apiClient.interceptors.response.use(
  (response: AxiosResponse): AxiosResponse => {
    return response;
  },
  (error) => {
    // Handle 401 Unauthorized errors
    if (error.response?.status === 401) {
      // Clear token and redirect to login
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    // Handle 403 Forbidden errors
    if (error.response?.status === 403) {
      console.error('Access denied');
    }
    return Promise.reject(error);
  },
);

// Authentication API methods
export const authAPI = {
  login: async (email: string, password: string) => {
    const response = await apiClient.post('/users/sign_in', {
      user: { email, password },
    });
    // Devise JWT returns token in Authorization header
    const authHeader = response.headers.authorization || response.headers.Authorization;
    const token = authHeader ? authHeader.replace('Bearer ', '') : null;
    return { ...response, token };
  },
  logout: async () => {
    const response = await apiClient.delete('/users/sign_out');
    return response;
  },
  getProfile: async () => {
    const response = await apiClient.get('/auth/profile');
    return response;
  },
};

// API methods for departments
export const departmentsAPI = {
  getAll: async () => {
    const response = await apiClient.get('/departments');
    return response.data;
  },
  getOne: async (id: number) => {
    const response = await apiClient.get(`/departments/${id}`);
    return response.data;
  },
  create: async (data: any) => {
    const response = await apiClient.post('/departments', data);
    return response.data;
  },
  update: async (id: number, data: any) => {
    const response = await apiClient.put(`/departments/${id}`, data);
    return response.data;
  },
  delete: async (id: number) => {
    const response = await apiClient.delete(`/departments/${id}`);
    return response.data;
  },
};

// API methods for employees
export const employeesAPI = {
  getAll: async () => {
    const response = await apiClient.get('/employees');
    return response.data;
  },
  getOne: async (id: number) => {
    const response = await apiClient.get(`/employees/${id}`);
    return response.data;
  },
  create: async (data: any) => {
    const response = await apiClient.post('/employees', data);
    return response.data;
  },
  update: async (id: number, data: any) => {
    const response = await apiClient.put(`/employees/${id}`, data);
    return response.data;
  },
  delete: async (id: number) => {
    const response = await apiClient.delete(`/employees/${id}`);
    return response.data;
  },
};

export default apiClient;