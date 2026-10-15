import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useEmployees, useEmployeeMutation } from '../../hooks/useEmployeeData';

const EmployeeList: React.FC = () => {
  const [deleteConfirmId, setDeleteConfirmId] = useState<number | null>(null);
  const { employees, loading, error, refetch } = useEmployees();
  const { deleteEmployee, loading: deleteLoading } = useEmployeeMutation();
  const navigate = useNavigate();

  const handleDelete = async (id: number) => {
    if (deleteConfirmId !== id) {
      setDeleteConfirmId(id);
      return;
    }
    
    try {
      await deleteEmployee(id);
      setDeleteConfirmId(null);
      refetch();
    } catch (err) {
      // Error is handled in the hook
    }
  };

  const handleEdit = (id: number) => {
    navigate(`/employees/${id}/edit`);
  };

  const handleView = (id: number) => {
    navigate(`/employees/${id}`);
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

  return (
    <div>
      <div className="flex" style={{ marginBottom: '1rem' }}>
        <h1 style={{ color: 'var(--color-text-primary)' }}>Employees</h1>
        <button 
          className="btn btn-primary"
          onClick={() => navigate('/employees/new')}
        >
          Add Employee
        </button>
      </div>
      
      <div className="card">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Email</th>
              <th>Department</th>
              <th>Job Title</th>
              <th>Hire Date</th>
              <th>Salary</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {employees.map((employee: any) => (
              <tr key={employee.id}>
                <td>{employee.id}</td>
                <td>{employee.first_name} {employee.last_name}</td>
                <td>{employee.email}</td>
                <td>{employee.department?.name || 'N/A'}</td>
                <td>{employee.job_title || 'N/A'}</td>
                <td>{employee.hire_date || 'N/A'}</td>
                <td>${employee.salary?.toLocaleString() || 'N/A'}</td>
                <td>
                  <div style={{ display: 'flex', gap: '0.5rem' }}>
                    <button 
                      className="btn btn-secondary"
                      style={{ padding: '0.25rem 0.75rem', fontSize: '0.75rem' }}
                      onClick={() => handleView(employee.id)}
                    >
                      View
                    </button>
                    <button 
                      className="btn btn-secondary"
                      style={{ padding: '0.25rem 0.75rem', fontSize: '0.75rem' }}
                      onClick={() => handleEdit(employee.id)}
                    >
                      Edit
                    </button>
                    <button 
                      className="btn btn-danger"
                      style={{ padding: '0.25rem 0.75rem', fontSize: '0.75rem' }}
                      onClick={() => handleDelete(employee.id)}
                      disabled={deleteLoading}
                    >
                      {deleteConfirmId === employee.id ? 'Confirm?' : 'Delete'}
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default EmployeeList;