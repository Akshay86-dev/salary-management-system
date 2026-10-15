import React from 'react';
import { useReports } from '../../hooks/useReportsData';

const ReportsDashboard: React.FC = () => {
  const {
    salaryTotalsByDepartment,
    averageSalaryByJobTitle,
    departmentComparison,
    salaryByCurrency,
    loading,
    error,
    refetch,
  } = useReports();

  if (loading) {
    return (
      <div className="flex-center" style={{ padding: '2rem' }}>
        <span className="loader"></span>
      </div>
    );
  }

  if (error) {
    return (
      <div style={{ color: 'var(--color-error)', padding: '1rem' }}>
        {error}
      </div>
    );
  }

  return (
    <div>
      <div className="flex" style={{ marginBottom: '1rem' }}>
        <h1 style={{ color: 'var(--color-text-primary)' }}>Reports Dashboard</h1>
        <button className="btn btn-secondary" onClick={refetch}>
          Refresh Data
        </button>
      </div>

      <div className="card" style={{ marginBottom: '2rem' }}>
        <h2 style={{ color: 'var(--color-text-primary)', marginBottom: '1rem' }}>Salary Totals by Department</h2>
        <table>
          <thead>
            <tr><th>Department</th><th>Total Salary</th></tr>
          </thead>
          <tbody>
            {salaryTotalsByDepartment.map((item: any) => (
              <tr key={item.department}>
                <td>{item.department}</td>
                <td>{item.formatted_total || `$${item.total_salary?.toLocaleString()}`}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="card" style={{ marginBottom: '2rem' }}>
        <h2 style={{ color: 'var(--color-text-primary)', marginBottom: '1rem' }}>Average Salary by Job Title</h2>
        <table>
          <thead>
            <tr><th>Job Title</th><th>Average Salary</th></tr>
          </thead>
          <tbody>
            {averageSalaryByJobTitle.map((item: any) => (
              <tr key={item.job_title}>
                <td>{item.job_title}</td>
                <td>{item.formatted_average || `$${item.average_salary?.toLocaleString()}`}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="card" style={{ marginBottom: '2rem' }}>
        <h2 style={{ color: 'var(--color-text-primary)', marginBottom: '1rem' }}>Department Comparison</h2>
        <table>
          <thead>
            <tr><th>Department</th><th>Budget</th><th>Employees</th><th>Total Salary</th><th>Average Salary</th></tr>
          </thead>
          <tbody>
            {departmentComparison.map((item: any) => (
              <tr key={item.department}>
                <td>{item.department}</td>
                <td>${item.budget?.toLocaleString() || 'N/A'}</td>
                <td>{item.employee_count}</td>
                <td>{item.formatted_total_salary || `$${item.total_salary?.toLocaleString()}`}</td>
                <td>{item.formatted_average_salary || `$${item.average_salary?.toLocaleString()}`}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="card">
        <h2 style={{ color: 'var(--color-text-primary)', marginBottom: '1rem' }}>Salary by Currency</h2>
        <table>
          <thead>
            <tr><th>Currency</th><th>Total Amount</th></tr>
          </thead>
          <tbody>
            {salaryByCurrency.map((item: any) => (
              <tr key={item.currency}>
                <td>{item.currency}</td>
                <td>{item.formatted_total || `${item.total_amount?.toLocaleString()}`}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default ReportsDashboard;