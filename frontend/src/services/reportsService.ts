import apiClient from './api';

// Reports service
export const reportsService = {
  // Get salary totals by department
  salaryTotalsByDepartment: async () => {
    const response = await apiClient.get('/reports/salary_totals_by_department');
    return response.data;
  },

  // Get average salary by job title
  averageSalaryByJobTitle: async () => {
    const response = await apiClient.get('/reports/average_salary_by_job_title');
    return response.data;
  },

  // Get department comparison data
  departmentComparison: async () => {
    const response = await apiClient.get('/reports/department_comparison');
    return response.data;
  },

  // Get salary totals by currency
  salaryByCurrency: async () => {
    const response = await apiClient.get('/reports/salary_by_currency');
    return response.data;
  },
};

export default reportsService;