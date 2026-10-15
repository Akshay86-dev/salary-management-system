import apiClient from './api';

// Employee interface
export interface Employee {
  id: number;
  first_name: string;
  last_name: string;
  email: string;
  job_title: string;
  department_id?: number;
  department?: {
    id: number;
    name: string;
  };
  hire_date: string;
  salary?: number;
  created_at?: string;
  updated_at?: string;
}

export interface EmployeeFilters {
  query?: string;
  country?: string;
  departmentId?: string;
  status?: 'all' | 'active' | 'inactive';
}

interface JsonApiEmployee {
  id: number | string;
  attributes: Pick<Employee, 'first_name' | 'last_name' | 'email' | 'job_title' | 'hire_date'> & {
    employee_id?: string;
    is_active?: boolean;
    department_id?: number;
    department_name?: string | null;
    salary?: number | string | null;
    full_name?: string;
  };
  relationships?: {
    department?: {
      data?: { id: number | string } | null;
    };
  };
}

export const normalizeEmployee = (record: Employee | JsonApiEmployee): Employee => {
  if (!('attributes' in record)) {
    return record;
  }

  const departmentId = record.relationships?.department?.data?.id;
  const departmentName = record.attributes.department_name;
  const salary = record.attributes.salary;

  return {
    ...record.attributes,
    id: Number(record.id),
    department_id: departmentId === undefined ? record.attributes.department_id : Number(departmentId),
    department: departmentName && departmentId !== undefined
      ? { id: Number(departmentId), name: departmentName }
      : undefined,
    salary: salary == null ? undefined : Number(salary),
  };
};

// Employee service
export const employeeService = {
  // Fetch all employees
  getAll: async (filters: EmployeeFilters = {}) => {
    const params = {
      query: filters.query || undefined,
      country: filters.country || undefined,
      department_id: filters.departmentId || undefined,
      status: filters.status && filters.status !== 'all' ? filters.status : undefined,
    };
    const response = await apiClient.get('/employees', { params });
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