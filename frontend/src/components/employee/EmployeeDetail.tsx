import React from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useEmployee, useEmployeeMutation } from '../../hooks/useEmployeeData';

const EmployeeDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const employeeId = id ? parseInt(id, 10) : 0;
  const { employee, loading, error, refetch } = useEmployee(employeeId);
  const { deleteEmployee } = useEmployeeMutation();
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
    </div>
  );
};

export default EmployeeDetail;