import React, { useEffect, useState } from 'react';
import dashboardService, { DashboardStats } from '../services/dashboardService';

const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        setStats(await dashboardService.getStats());
      } catch (err: any) {
        setError(err.response?.data?.error || err.message || 'Failed to load dashboard stats');
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  return (
    <div>
      <h1 style={{ marginBottom: '1rem', color: 'var(--color-text-primary)' }}>
        Dashboard
      </h1>
      {error && (
        <div style={{ color: 'var(--color-error)', padding: '1rem' }} role="alert">
          {error}
        </div>
      )}
      <div className="grid">
        <div className="card">
          <h3 style={{ color: 'var(--color-text-secondary)', marginBottom: '0.5rem' }}>
            Total Departments
          </h3>
          <p style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--color-primary)' }}>
            {loading ? '…' : stats?.total_departments ?? 0}
          </p>
        </div>
        <div className="card">
          <h3 style={{ color: 'var(--color-text-secondary)', marginBottom: '0.5rem' }}>
            Total Employees
          </h3>
          <p style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--color-primary)' }}>
            {loading ? '…' : stats?.total_employees ?? 0}
          </p>
        </div>
        <div className="card">
          <h3 style={{ color: 'var(--color-text-secondary)', marginBottom: '0.5rem' }}>
            Total Salaries
          </h3>
          <p style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--color-primary)' }}>
            {loading ? '…' : stats?.total_salaries ?? 0}
          </p>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;