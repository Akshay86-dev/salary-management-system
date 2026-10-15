import { useState, useEffect, useCallback } from 'react';
import salaryService, { Salary } from '../services/salaryService';
import employeeService from '../services/employeeService';

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
      setSalaries(data.data || data.salaries || []);
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
      setSalary(data.data || data.salary || null);
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
      const errorMsg = err.response?.data?.errors?.[0] || err.message || 'Failed to create salary';
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
      const errorMsg = err.response?.data?.errors?.[0] || err.message || 'Failed to update salary';
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
      const errorMsg = err.response?.data?.errors?.[0] || err.message || 'Failed to delete salary';
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
  const [employees, setEmployees] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchEmployees = async () => {
      setLoading(true);
      setError(null);
      try {
        const data = await employeeService.getAll();
        setEmployees(data.data || data.employees || []);
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