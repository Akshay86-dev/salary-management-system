import apiClient from './api';

// Salary interface
export interface Salary {
  id: number;
  employee_id: number;
  amount: number;
  currency: string;
  salary_type: number;
  effective_date: string;
  is_current: boolean;
  formatted_amount: string;
  employee?: {
    id: number;
    first_name: string;
    last_name: string;
  };
  created_at: string;
  updated_at: string;
}

// Salary service
export const salaryService = {
  // Fetch all salaries for an employee
  getAllForEmployee: async (employeeId: number) => {
    const response = await apiClient.get(`/salaries?employee_id=${employeeId}&active=true`);
    return response.data;
  },

  // Fetch a single salary by ID
  getById: async (id: number) => {
    const response = await apiClient.get(`/salaries/${id}`);
    return response.data;
  },

  // Create a new salary record
  create: async (salaryData: Partial<Salary>) => {
    const response = await apiClient.post('/salaries', { data: { attributes: salaryData } });
    return response.data;
  },

  // Update an existing salary record
  update: async (id: number, salaryData: Partial<Salary>) => {
    const response = await apiClient.put(`/salaries/${id}`, { data: { attributes: salaryData } });
    return response.data;
  },

  // Delete a salary record
  delete: async (id: number) => {
    const response = await apiClient.delete(`/salaries/${id}`);
    return response.data;
  },
};

export default salaryService;