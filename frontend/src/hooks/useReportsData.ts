import { useState, useEffect, useCallback } from 'react';
import reportsService from '../services/reportsService';
import {
  CurrencySalaryTotal,
  DepartmentSalaryComparison,
  DepartmentSalaryTotal,
  JobTitleSalaryAverage,
} from '../services/reportsService';
import { errorMessage } from '../services/errorMessage';

// Custom hook for fetching reports data
export const useReports = () => {
  const [salaryTotalsByDepartment, setSalaryTotalsByDepartment] = useState<DepartmentSalaryTotal[]>([]);
  const [averageSalaryByJobTitle, setAverageSalaryByJobTitle] = useState<JobTitleSalaryAverage[]>([]);
  const [departmentComparison, setDepartmentComparison] = useState<DepartmentSalaryComparison[]>([]);
  const [salaryByCurrency, setSalaryByCurrency] = useState<CurrencySalaryTotal[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchReports = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [totalsData, avgData, deptData, currencyData] = await Promise.allSettled([
        reportsService.salaryTotalsByDepartment(),
        reportsService.averageSalaryByJobTitle(),
        reportsService.departmentComparison(),
        reportsService.salaryByCurrency(),
      ]);

      if (totalsData.status === 'fulfilled') {
        setSalaryTotalsByDepartment(totalsData.value.data || []);
      }
      if (avgData.status === 'fulfilled') {
        setAverageSalaryByJobTitle(avgData.value.data || []);
      }
      if (deptData.status === 'fulfilled') {
        setDepartmentComparison(deptData.value.data || []);
      }
      if (currencyData.status === 'fulfilled') {
        setSalaryByCurrency(currencyData.value.data || []);
      }

      const failedRequests = [totalsData, avgData, deptData, currencyData].filter(
        (r) => r.status === 'rejected'
      );
      if (failedRequests.length === 4) {
        setError('Failed to fetch report data');
      }
    } catch (err) {
      setError(errorMessage(err, 'Failed to fetch reports'));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchReports();
  }, [fetchReports]);

  return {
    salaryTotalsByDepartment,
    averageSalaryByJobTitle,
    departmentComparison,
    salaryByCurrency,
    loading,
    error,
    refetch: fetchReports,
  };
};