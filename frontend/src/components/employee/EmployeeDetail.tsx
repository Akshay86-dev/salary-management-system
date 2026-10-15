import React from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useEmployee, useEmployeeMutation } from '../../hooks/useEmployeeData';
import { useSalaries, useSalaryMutation } from '../../hooks/useSalaryData';

const EmployeeDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const employeeId = id ? parseInt(id, 10) : 0;
  const { employee, loading, error, refetch } = useEmployee(employeeId);
  const { deleteEmployee } = useEmployeeMutation();
  const { salaries, loading: salariesLoading, error: salariesError, refetch: refetchSalaries } = useSalaries(employeeId);
  const { deleteSalary, loading: salaryMutationLoading, error: salaryMutationError } = useSalaryMutation();
  const [deletingSalaryId, setDeletingSalaryId] = React.useState<number | null>(null);
  const navigate = useNavigate();

  const handleDelete = async () => {
    if (window.confirm('Are you sure you want to delete this employee?')) {
      try {
        await deleteEmployee(employeeId);
        navigate('/employees');
      } catch (err) {
        // Error is handled in the hook
      }
    }
    };

  const handleEdit = () => {
    navigate(`/employees/${employeeId}/edit`);
  };

  const handleAddSalary = () => {
    navigate(`/employees/${employeeId}/salary/new`);
  };

  const handleEditSalary = (salaryId: number) => {
    navigate(`/employees/${employeeId}/salary/${salaryId}/edit`);
  };

  const handleDeleteSalary = async (salaryId: number) => {
    if (!window.confirm('Are you sure you want to delete this salary record?')) {
      return;
    }

    setDeletingSalaryId(salaryId);
    try {
      await deleteSalary(salaryId);
      await refetchSalaries();
      await refetch();
    } catch {
      // The mutation hook exposes the error for display.
    } finally {
      setDeletingSalaryId(null);
    }
  };

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

  if (!employee) {
    return (
      <div style={{ padding: '1rem', color: 'var(--color-text-secondary)' }}>
        Employee not found or has been deleted.
      </div>
    );
  }

  return (
    <div>
      <div className="flex" style={{ marginBottom: '1rem' }}>
        <h1 style={{ color: 'var(--color-text-primary)' }}>
          {employee.first_name} {employee.last_name}
        </h1>
        <div style={{ display: 'flex', gap: '0.5rem' }}>
          <button 
            className="btn btn-secondary"
            onClick={handleEdit}
          >
            Edit
          </button>
          <button 
            className="btn btn-secondary"
            onClick={handleAddSalary}
          >
            Add Salary
          </button>
          <button 
            className="btn btn-danger"
            onClick={handleDelete}
          >
            Delete
          </button>
          <button 
            className="btn btn-secondary"
            onClick={() => navigate('/employees')}
          >
            Back to List
          </button>
        </div>
      </div>

      <div className="card">
        <h3 style={{ color: 'var(--color-text-secondary)', marginBottom: '1rem' }}>
          Employee Information
        </h3>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
          <div>
            <label style={{ display: 'block', color: 'var(--color-text-secondary)', marginBottom: '0.25rem' }}>
              First Name
            </label>
            <p style={{ color: 'var(--color-text-primary)' }}>{employee.first_name}</p>
          </div>
          <div>
            <label style={{ display: 'block', color: 'var(--color-text-secondary)', marginBottom: '0.25rem' }}>
              Last Name
            </label>
            <p style={{ color: 'var(--color-text-primary)' }}>{employee.last_name}</p>
          </div>
          <div>
            <label style={{ display: 'block', color: 'var(--color-text-secondary)', marginBottom: '0.25rem' }}>
              Email
            </label>
            <p style={{ color: 'var(--color-text-primary)' }}>{employee.email}</p>
          </div>
          <div>
            <label style={{ display: 'block', color: 'var(--color-text-secondary)', marginBottom: '0.25rem' }}>
              Job Title
            </label>
            <p style={{ color: 'var(--color-text-primary)' }}>{employee.job_title || 'N/A'}</p>
          </div>
          <div>
            <label style={{ display: 'block', color: 'var(--color-text-secondary)', marginBottom: '0.25rem' }}>
              Department
            </label>
            <p style={{ color: 'var(--color-text-primary)' }}>{employee.department?.name || 'N/A'}</p>
          </div>
          <div>
            <label style={{ display: 'block', color: 'var(--color-text-secondary)', marginBottom: '0.25rem' }}>
              Salary
            </label>
            <p style={{ color: 'var(--color-text-primary)' }}>
              ${employee.salary?.toLocaleString() || 'N/A'}
            </p>
          </div>
          <div>
            <label style={{ display: 'block', color: 'var(--color-text-secondary)', marginBottom: '0.25rem' }}>
              Hire Date
            </label>
            <p style={{ color: 'var(--color-text-primary)' }}>{employee.hire_date || 'N/A'}</p>
          </div>
          <div>
            <label style={{ display: 'block', color: 'var(--color-text-secondary)', marginBottom: '0.25rem' }}>
              Employee ID
            </label>
            <p style={{ color: 'var(--color-text-primary)' }}>{employee.id}</p>
          </div>
        </div>
      </div>

      <section className="card" style={{ marginTop: '1rem' }}>
        <div className="flex" style={{ marginBottom: '1rem' }}>
          <h2 style={{ color: 'var(--color-text-primary)' }}>Salary History</h2>
        </div>

        {(salariesError || salaryMutationError) && (
          <p role="alert" style={{ color: 'var(--color-error)', marginBottom: '1rem' }}>
            {salariesError || salaryMutationError}
          </p>
        )}

        {salariesLoading ? (
          <div className="flex-center" style={{ padding: '1rem' }}>
            <span className="loader" aria-label="Loading salary history" />
          </div>
        ) : salaries.length === 0 ? (
          <p style={{ color: 'var(--color-text-secondary)' }}>No salary records found.</p>
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table>
              <thead>
                <tr>
                  <th>Effective Date</th>
                  <th>Type</th>
                  <th>Amount</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {[...salaries]
                  .sort((a, b) => a.effective_date.localeCompare(b.effective_date) || a.id - b.id)
                  .map((salary) => (
                    <tr key={salary.id}>
                      <td>{salary.effective_date}</td>
                      <td>{['Base', 'Bonus', 'Commission', 'Equity'][salary.salary_type] || 'Other'}</td>
                      <td>{salary.currency} {salary.amount.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</td>
                      <td>{salary.is_current ? 'Current' : 'Previous'}</td>
                      <td>
                        <div style={{ display: 'flex', gap: '0.5rem' }}>
                          <button
                            className="btn btn-secondary"
                            onClick={() => handleEditSalary(salary.id)}
                            aria-label={`Edit ${salary.effective_date} salary`}
                          >
                            Edit
                          </button>
                          <button
                            className="btn btn-danger"
                            onClick={() => handleDeleteSalary(salary.id)}
                            disabled={salaryMutationLoading}
                            aria-label={`Delete ${salary.effective_date} salary`}
                          >
                            {deletingSalaryId === salary.id ? 'Deleting…' : 'Delete'}
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
              </tbody>
            </table>
          </div>
        )}
      </section>
    </div>
  );
};

export default EmployeeDetail;