import { useState, useEffect, useCallback } from 'react';
import employeeService, { Employee, EmployeeFilters, normalizeEmployee } from '../services/employeeService';
import { normalizeDepartment } from '../services/departmentService';

// Custom hook for fetching all employees
export const useEmployees = (filters: EmployeeFilters = {}) => {
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchEmployees = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await employeeService.getAll(filters);
      setEmployees((data.data || data.employees || []).map(normalizeEmployee));
    } catch (err: any) {
      setError(err.response?.data?.errors?.[0] || err.message || 'Failed to fetch employees');
    } finally {
      setLoading(false);
    }
  }, [filters.query, filters.country, filters.departmentId, filters.status]);

  const refresh = useCallback(async () => {
    await fetchEmployees();
  }, [fetchEmployees]);

  useEffect(() => {
    fetchEmployees();
  }, [fetchEmployees]);

  return {
    employees,
    loading,
    error,
    refetch: refresh,
  };
};

// Custom hook for fetching a single employee
export const useEmployee = (id: number) => {
  const [employee, setEmployee] = useState<Employee | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchEmployee = useCallback(async () => {
    if (!id) return;
    
    setLoading(true);
    setError(null);
    try {
      const data = await employeeService.getById(id);
      const result = data.data || data.employee || null;
      setEmployee(result ? normalizeEmployee(result) : null);
    } catch (err: any) {
      setError(err.response?.data?.errors?.[0] || err.message || 'Failed to fetch employee');
    } finally {
      setLoading(false);
    }
  }, [id]);

  const refresh = useCallback(async () => {
    await fetchEmployee();
  }, [fetchEmployee]);

  useEffect(() => {
    fetchEmployee();
  }, [fetchEmployee]);

  return {
    employee,
    loading,
    error,
    refetch: refresh,
  };
};

// Custom hook for fetching departments
export const useDepartments = () => {
  const [departments, setDepartments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchDepartments = async () => {
      setLoading(true);
      setError(null);
      try {
        const data = await employeeService.getAllDepartments();
        setDepartments((data.data || data.departments || []).map(normalizeDepartment));
      } catch (err: any) {
        setError(err.response?.data?.errors?.[0] || err.message || 'Failed to fetch departments');
      } finally {
        setLoading(false);
      }
    };

    fetchDepartments();
  }, []);

  return {
    departments,
    loading,
    error,
  };
};

// Custom hook for employee mutations
export const useEmployeeMutation = () => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const createEmployee = useCallback(async (data: Partial<Employee>) => {
    setLoading(true);
    setError(null);
    try {
      const result = await employeeService.create(data);
      return result;
    } catch (err: any) {
      const errorMsg = err.response?.data?.errors?.[0] || err.message || 'Failed to create employee';
      setError(errorMsg);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const updateEmployee = useCallback(async (id: number, data: Partial<Employee>) => {
    setLoading(true);
    setError(null);
    try {
      const result = await employeeService.update(id, data);
      return result;
    } catch (err: any) {
      const errorMsg = err.response?.data?.errors?.[0] || err.message || 'Failed to update employee';
      setError(errorMsg);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const deleteEmployee = useCallback(async (id: number) => {
    setLoading(true);
    setError(null);
    try {
      const result = await employeeService.delete(id);
      return result;
    } catch (err: any) {
      const errorMsg = err.response?.data?.errors?.[0] || err.message || 'Failed to delete employee';
      setError(errorMsg);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  return {
    loading,
    error,
    createEmployee,
    updateEmployee,
    deleteEmployee,
  };
};