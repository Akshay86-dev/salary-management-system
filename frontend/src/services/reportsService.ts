import apiClient from './api';

export interface DepartmentSalaryTotal {
  department: string;
  currency: string;
  total_salary: number | string;
  formatted_total: string;
}

export interface JobTitleSalaryAverage {
  job_title: string;
  currency: string;
  average_salary: number;
  formatted_average: string;
}

export interface DepartmentCurrencySalary {
  currency: string;
  total_salary: number | string;
  average_salary: number;
  formatted_total_salary: string;
  formatted_average_salary: string;
}

export interface DepartmentSalaryComparison {
  department: string;
  budget: number | string | null;
  employee_count: number;
  salary_by_currency: DepartmentCurrencySalary[];
}

export interface CurrencySalaryTotal {
  currency: string;
  total_amount: number | string;
  formatted_total: string;
}

interface ReportResponse<T> {
  data: T[];
  summary: Record<string, unknown>;
}

// Reports service
export const reportsService = {
  // Get salary totals by department
  salaryTotalsByDepartment: async (): Promise<ReportResponse<DepartmentSalaryTotal>> => {
    const response = await apiClient.get('/reports/salary_totals_by_department');
    return response.data;
  },

  // Get average salary by job title
  averageSalaryByJobTitle: async (): Promise<ReportResponse<JobTitleSalaryAverage>> => {
    const response = await apiClient.get('/reports/average_salary_by_job_title');
    return response.data;
  },

  // Get department comparison data
  departmentComparison: async (): Promise<ReportResponse<DepartmentSalaryComparison>> => {
    const response = await apiClient.get('/reports/department_comparison');
    return response.data;
  },

  // Get salary totals by currency
  salaryByCurrency: async (): Promise<ReportResponse<CurrencySalaryTotal>> => {
    const response = await apiClient.get('/reports/salary_by_currency');
    return response.data;
  },
};

export default reportsService;