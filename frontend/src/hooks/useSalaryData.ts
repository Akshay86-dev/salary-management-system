import { useState, useEffect, useCallback } from 'react';
import salaryService, { normalizeSalary, Salary } from '../services/salaryService';
import employeeService, { Employee, normalizeEmployee } from '../services/employeeService';

// Custom hook for fetching all salaries for an employee
export const useSalaries = (employeeId: number) => {
  const [salaries, setSalaries] = useState<Salary[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchSalaries = useCallback(async () => {
    if (!employeeId) return;

    setLoading(true);
    setError(null);
    try {
      const data = await salaryService.getAllForEmployee(employeeId);
      setSalaries((data.data || data.salaries || []).map(normalizeSalary));
    } catch (err: any) {
      setError(err.response?.data?.errors?.[0] || err.message || 'Failed to fetch salaries');
    } finally {
      setLoading(false);
    }
  }, [employeeId]);

  useEffect(() => {
    fetchSalaries();
  }, [fetchSalaries]);

  return {
    salaries,
    loading,
    error,
    refetch: fetchSalaries,
  };
};

// Custom hook for fetching a single salary
export const useSalary = (id: number) => {
  const [salary, setSalary] = useState<Salary | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchSalary = useCallback(async () => {
    if (!id) return;

    setLoading(true);
    setError(null);
    try {
      const data = await salaryService.getById(id);
      const result = data.data || data.salary || null;
      setSalary(result ? normalizeSalary(result) : null);
    } catch (err: any) {
      setError(err.response?.data?.errors?.[0] || err.message || 'Failed to fetch salary');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    fetchSalary();
  }, [fetchSalary]);

  return {
    salary,
    loading,
    error,
    refetch: fetchSalary,
  };
};

// Custom hook for salary mutations
const getErrorMessage = (err: any, fallback: string) => {
  const backendErrors = err.response?.data?.errors;

  if (Array.isArray(backendErrors)) {
    return backendErrors[0] || fallback;
  }

  if (typeof backendErrors === 'string') {
    return backendErrors;
  }

  if (backendErrors && typeof backendErrors === 'object') {
    const firstValue = Object.values(backendErrors)
      .flatMap((value: any) => Array.isArray(value) ? value : [value])
      .find((value) => value !== undefined && value !== null && value !== '');

    if (firstValue) {
      return String(firstValue);
    }
  }

  return err.response?.data?.error || err.message || fallback;
};

export const useSalaryMutation = () => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const createSalary = useCallback(async (data: Partial<Salary>) => {
    setLoading(true);
    setError(null);
    try {
      const result = await salaryService.create(data);
      return result;
    } catch (err: any) {
      const errorMsg = getErrorMessage(err, 'Failed to create salary');
      setError(errorMsg);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const updateSalary = useCallback(async (id: number, data: Partial<Salary>) => {
    setLoading(true);
    setError(null);
    try {
      const result = await salaryService.update(id, data);
      return result;
    } catch (err: any) {
      const errorMsg = getErrorMessage(err, 'Failed to update salary');
      setError(errorMsg);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const deleteSalary = useCallback(async (id: number) => {
    setLoading(true);
    setError(null);
    try {
      const result = await salaryService.delete(id);
      return result;
    } catch (err: any) {
      const errorMsg = getErrorMessage(err, 'Failed to delete salary');
      setError(errorMsg);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  return {
    loading,
    error,
    createSalary,
    updateSalary,
    deleteSalary,
  };
};

// Helper hook for fetching employees (needed by salary form)
export const useEmployeeOptions = () => {
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchEmployees = async () => {
      setLoading(true);
      setError(null);
      try {
        const data = await employeeService.getAll();
        setEmployees((data.data || data.employees || []).map(normalizeEmployee));
      } catch (err: any) {
        setError(err.response?.data?.errors?.[0] || err.message || 'Failed to fetch employees');
      } finally {
        setLoading(false);
      }
    };

    fetchEmployees();
  }, []);

  return { employees, loading, error };
};