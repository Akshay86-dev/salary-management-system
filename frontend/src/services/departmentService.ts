import apiClient from './api';
import { JsonApiCollection, JsonApiRecord } from './apiTypes';

// Department interface
export interface Department {
  id: number;
  name: string;
  budget: number | null;
  manager_id: number | null;
  created_at?: string;
  updated_at?: string;
}

export interface JsonApiDepartment {
  id: number | string;
  attributes: {
    name: string;
    budget: number | string | null;
    manager_id: number | string | null;
  };
}

export const normalizeDepartment = (record: Department | JsonApiDepartment): Department => {
  if (!('attributes' in record)) {
    return record;
  }

  const { budget, manager_id } = record.attributes;
  return {
    id: Number(record.id),
    name: record.attributes.name,
    budget: budget == null ? null : Number(budget),
    manager_id: manager_id == null ? null : Number(manager_id),
  };
};

// Department service
export const departmentService = {
  // Fetch all departments
  getAll: async (): Promise<JsonApiCollection<JsonApiDepartment>> => {
    const response = await apiClient.get('/departments');
    return response.data;
  },

  // Fetch a single department by ID
  getById: async (id: number): Promise<JsonApiRecord<JsonApiDepartment>> => {
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