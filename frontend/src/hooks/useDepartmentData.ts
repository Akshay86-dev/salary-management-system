import { useState, useEffect, useCallback } from 'react';
import departmentService, { Department } from '../services/departmentService';

// Custom hook for fetching all departments
export const useDepartments = () => {
  const [departments, setDepartments] = useState<Department[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchDepartments = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await departmentService.getAll();
      setDepartments(data.data || data.departments || []);
    } catch (err: any) {
      setError(err.response?.data?.errors?.[0] || err.message || 'Failed to fetch departments');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchDepartments();
  }, [fetchDepartments]);

  return {
    departments,
    loading,
    error,
    refetch: fetchDepartments,
  };
};

// Custom hook for fetching a single department
export const useDepartment = (id: number) => {
  const [department, setDepartment] = useState<Department | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchDepartment = useCallback(async () => {
    if (!id) return;

    setLoading(true);
    setError(null);
    try {
      const data = await departmentService.getById(id);
      setDepartment(data.data || data.department || null);
    } catch (err: any) {
      setError(err.response?.data?.errors?.[0] || err.message || 'Failed to fetch department');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    fetchDepartment();
  }, [fetchDepartment]);

  return {
    department,
    loading,
    error,
    refetch: fetchDepartment,
  };
};

// Custom hook for department mutations
export const useDepartmentMutation = () => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const createDepartment = useCallback(async (data: Partial<Department>) => {
    setLoading(true);
    setError(null);
    try {
      const result = await departmentService.create(data);
      return result;
    } catch (err: any) {
      const errorMsg = err.response?.data?.errors?.[0] || err.message || 'Failed to create department';
      setError(errorMsg);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const updateDepartment = useCallback(async (id: number, data: Partial<Department>) => {
    setLoading(true);
    setError(null);
    try {
      const result = await departmentService.update(id, data);
      return result;
    } catch (err: any) {
      const errorMsg = err.response?.data?.errors?.[0] || err.message || 'Failed to update department';
      setError(errorMsg);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const deleteDepartment = useCallback(async (id: number) => {
    setLoading(true);
    setError(null);
    try {
      const result = await departmentService.delete(id);
      return result;
    } catch (err: any) {
      const errorMsg = err.response?.data?.errors?.[0] || err.message || 'Failed to delete department';
      setError(errorMsg);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  return {
    loading,
    error,
    createDepartment,
    updateDepartment,
    deleteDepartment,
  };
};