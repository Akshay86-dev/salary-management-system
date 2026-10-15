import React, { useEffect, useState } from 'react';
import { departmentsAPI } from '../services/api';

const Departments: React.FC = () => {
  const [departments, setDepartments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchDepartments = async () => {
      try {
        const response = await departmentsAPI.getAll();
        setDepartments(response.data || []);
      } catch (err) {
        setError('Failed to load departments');
      } finally {
        setLoading(false);
      }
    };

    fetchDepartments();
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
        <h1 style={{ color: 'var(--color-text-primary)' }}>Departments</h1>
      </div>
      
      <div className="card">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Location</th>
            </tr>
          </thead>
          <tbody>
            {departments.map((dept: any) => (
              <tr key={dept.id}>
                <td>{dept.id}</td>
                <td>{dept.name}</td>
                <td>{dept.location?.name || 'N/A'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Departments;