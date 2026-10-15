import React, { useEffect, useState } from 'react';
import { employeesAPI } from '../services/api';

const Employees: React.FC = () => {
  const [employees, setEmployees] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchEmployees = async () => {
      try {
        const response = await employeesAPI.getAll();
        setEmployees(response.data || []);
      } catch (err) {
        setError('Failed to load employees');
      } finally {
        setLoading(false);
      }
    };

    fetchEmployees();
  }, []);

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
            </tr>
          </thead>
          <tbody>
            {employees.map((emp: any) => (
              <tr key={emp.id}>
                <td>{emp.id}</td>
                <td>{emp.first_name} {emp.last_name}</td>
                <td>{emp.email}</td>
                <td>{emp.department?.name || 'N/A'}</td>
                <td>{emp.job_title || 'N/A'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Employees;