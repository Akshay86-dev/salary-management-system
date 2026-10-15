import apiClient from './api';

export interface DashboardStats {
  total_departments: number;
  total_employees: number;
  total_countries: number;
  employees_by_department: Array<{ name: string; count: number }>;
  employees_by_country: Array<{ name: string; count: number }>;
}

const dashboardService = {
  getStats: async (): Promise<DashboardStats> => {
    const response = await apiClient.get('/dashboard/stats');
    return response.data.data;
  },
};

export default dashboardService;
