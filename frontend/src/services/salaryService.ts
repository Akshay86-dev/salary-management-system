import apiClient from './api';
import { JsonApiCollection, JsonApiRecord } from './apiTypes';

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

export interface JsonApiSalary {
  id: number | string;
  attributes: Omit<Salary, 'id' | 'employee_id' | 'employee' | 'created_at' | 'updated_at'> & {
    employee_id?: number | string;
    created_at?: string;
    updated_at?: string;
  };
  relationships?: {
    employee?: {
      data?: { id: number | string } | null;
    };
  };
}

export const normalizeSalary = (record: Salary | JsonApiSalary): Salary => {
  if (!('attributes' in record)) {
    return record;
  }

  const employeeId = record.relationships?.employee?.data?.id ?? record.attributes.employee_id;

  return {
    ...record.attributes,
    id: Number(record.id),
    employee_id: Number(employeeId),
    amount: Number(record.attributes.amount),
    salary_type: Number(record.attributes.salary_type),
    created_at: record.attributes.created_at || '',
    updated_at: record.attributes.updated_at || '',
  };
};

// Salary service
export const salaryService = {
  // Fetch all salaries for an employee
  getAllForEmployee: async (employeeId: number): Promise<JsonApiCollection<JsonApiSalary>> => {
    const response = await apiClient.get('/salaries', { params: { employee_id: employeeId } });
    return response.data;
  },

  // Fetch a single salary by ID
  getById: async (id: number): Promise<JsonApiRecord<JsonApiSalary>> => {
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