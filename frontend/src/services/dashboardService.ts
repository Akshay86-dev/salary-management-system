import apiClient from './api';

export interface DashboardStats {
  total_departments: number;
  total_employees: number;
  total_salaries: number;
}

const dashboardService = {
  getStats: async (): Promise<DashboardStats> => {
    const response = await apiClient.get('/dashboard/stats');
    return response.data.data;
  },
};

export default dashboardService;
