import apiClient from './api';

// Department interface
export interface Department {
  id: number;
  name: string;
  budget: number | null;
  manager_id: number | null;
  created_at: string;
  updated_at: string;
}

// Department service
export const departmentService = {
  // Fetch all departments
  getAll: async () => {
    const response = await apiClient.get('/departments');
    return response.data;
  },

  // Fetch a single department by ID
  getById: async (id: number) => {
    const response = await apiClient.get(`/departments/${id}`);
    return response.data;
  },

  // Create a new department
  create: async (departmentData: Partial<Department>) => {
    const response = await apiClient.post('/departments', { data: { attributes: departmentData } });
    return response.data;
  },

  // Update an existing department
  update: async (id: number, departmentData: Partial<Department>) => {
    const response = await apiClient.put(`/departments/${id}`, { data: { attributes: departmentData } });
    return response.data;
  },

  // Delete a department
  delete: async (id: number) => {
    const response = await apiClient.delete(`/departments/${id}`);
    return response.data;
  },
};

export default departmentService;