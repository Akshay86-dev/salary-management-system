import React from 'react';
import { useReports } from '../../hooks/useReportsData';
import { usePagination } from '../../hooks/usePagination';
import Pagination from '../common/Pagination';

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
  const totalsPagination = usePagination(salaryTotalsByDepartment);
  const jobTitlePagination = usePagination(averageSalaryByJobTitle);
  const comparisonPagination = usePagination(departmentComparison);
  const currencyPagination = usePagination(salaryByCurrency);

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
            <tr><th>Department</th><th>Currency</th><th>Total Salary</th></tr>
          </thead>
          <tbody>
            {totalsPagination.items.map((item) => (
              <tr key={`${item.department}-${item.currency}`}>
                <td>{item.department}</td>
                <td>{item.currency}</td>
                <td>{item.formatted_total || `$${item.total_salary?.toLocaleString()}`}</td>
              </tr>
            ))}
          </tbody>
        </table>
        <Pagination
          page={totalsPagination.page}
          pageSize={totalsPagination.pageSize}
          totalItems={totalsPagination.totalItems}
          totalPages={totalsPagination.totalPages}
          startItem={totalsPagination.startItem}
          endItem={totalsPagination.endItem}
          onPageChange={totalsPagination.setPage}
          onPageSizeChange={totalsPagination.setPageSize}
        />
      </div>

      <div className="card" style={{ marginBottom: '2rem' }}>
        <h2 style={{ color: 'var(--color-text-primary)', marginBottom: '1rem' }}>Average Salary by Job Title</h2>
        <table>
          <thead>
            <tr><th>Job Title</th><th>Currency</th><th>Average Salary</th></tr>
          </thead>
          <tbody>
            {jobTitlePagination.items.map((item) => (
              <tr key={`${item.job_title}-${item.currency}`}>
                <td>{item.job_title}</td>
                <td>{item.currency}</td>
                <td>{item.formatted_average || `$${item.average_salary?.toLocaleString()}`}</td>
              </tr>
            ))}
          </tbody>
        </table>
        <Pagination
          page={jobTitlePagination.page}
          pageSize={jobTitlePagination.pageSize}
          totalItems={jobTitlePagination.totalItems}
          totalPages={jobTitlePagination.totalPages}
          startItem={jobTitlePagination.startItem}
          endItem={jobTitlePagination.endItem}
          onPageChange={jobTitlePagination.setPage}
          onPageSizeChange={jobTitlePagination.setPageSize}
        />
      </div>

      <div className="card" style={{ marginBottom: '2rem' }}>
        <h2 style={{ color: 'var(--color-text-primary)', marginBottom: '1rem' }}>Department Comparison</h2>
        <table>
          <thead>
            <tr><th>Department</th><th>Budget</th><th>Employees</th><th>Salary by Currency</th></tr>
          </thead>
          <tbody>
            {comparisonPagination.items.map((item) => (
              <tr key={item.department}>
                <td>{item.department}</td>
                <td>${item.budget?.toLocaleString() || 'N/A'}</td>
                <td>{item.employee_count}</td>
                <td>
                  {item.salary_by_currency.map((salary) => (
                    <div key={salary.currency}>
                      {salary.formatted_total_salary} total / {salary.formatted_average_salary} average
                    </div>
                  ))}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        <Pagination
          page={comparisonPagination.page}
          pageSize={comparisonPagination.pageSize}
          totalItems={comparisonPagination.totalItems}
          totalPages={comparisonPagination.totalPages}
          startItem={comparisonPagination.startItem}
          endItem={comparisonPagination.endItem}
          onPageChange={comparisonPagination.setPage}
          onPageSizeChange={comparisonPagination.setPageSize}
        />
      </div>

      <div className="card">
        <h2 style={{ color: 'var(--color-text-primary)', marginBottom: '1rem' }}>Salary by Currency</h2>
        <table>
          <thead>
            <tr><th>Currency</th><th>Total Amount</th></tr>
          </thead>
          <tbody>
            {currencyPagination.items.map((item) => (
              <tr key={item.currency}>
                <td>{item.currency}</td>
                <td>{item.formatted_total || `${item.total_amount?.toLocaleString()}`}</td>
              </tr>
            ))}
          </tbody>
        </table>
        <Pagination
          page={currencyPagination.page}
          pageSize={currencyPagination.pageSize}
          totalItems={currencyPagination.totalItems}
          totalPages={currencyPagination.totalPages}
          startItem={currencyPagination.startItem}
          endItem={currencyPagination.endItem}
          onPageChange={currencyPagination.setPage}
          onPageSizeChange={currencyPagination.setPageSize}
        />
      </div>
    </div>
  );
};

export default ReportsDashboard;