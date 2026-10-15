import apiClient from './api';

// Employee interface
export interface Employee {
  id: number;
  first_name: string;
  last_name: string;
  email: string;
  job_title: string;
  department_id: number;
  department?: {
    id: number;
    name: string;
  };
  hire_date: string;
  salary: number;
  created_at: string;
  updated_at: string;
}

// Employee service
export const employeeService = {
  // Fetch all employees
  getAll: async () => {
    const response = await apiClient.get('/employees');
    return response.data;
  },

  // Fetch a single employee by ID
  getById: async (id: number) => {
    const response = await apiClient.get(`/employees/${id}`);
    return response.data;
  },

  // Create a new employee
  create: async (employeeData: Partial<Employee>) => {
    const response = await apiClient.post('/employees', employeeData);
    return response.data;
  },

  // Update an existing employee
  update: async (id: number, employeeData: Partial<Employee>) => {
    const response = await apiClient.put(`/employees/${id}`, employeeData);
    return response.data;
  },

  // Delete an employee
  delete: async (id: number) => {
    const response = await apiClient.delete(`/employees/${id}`);
    return response.data;
  },

  // Fetch all departments for employee form
  getAllDepartments: async () => {
    const response = await apiClient.get('/departments');
    return response.data;
  },
};

export default employeeService;