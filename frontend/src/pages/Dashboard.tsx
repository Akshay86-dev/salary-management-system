import React from 'react';

const Dashboard: React.FC = () => {
  return (
    <div>
      <h1 style={{ marginBottom: '1rem', color: 'var(--color-text-primary)' }}>
        Dashboard
      </h1>
      <div className="grid">
        <div className="card">
          <h3 style={{ color: 'var(--color-text-secondary)', marginBottom: '0.5rem' }}>
            Total Departments
          </h3>
          <p style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--color-primary)' }}>
            0
          </p>
        </div>
        <div className="card">
          <h3 style={{ color: 'var(--color-text-secondary)', marginBottom: '0.5rem' }}>
            Total Employees
          </h3>
          <p style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--color-primary)' }}>
            0
          </p>
        </div>
        <div className="card">
          <h3 style={{ color: 'var(--color-text-secondary)', marginBottom: '0.5rem' }}>
            Total Salaries
          </h3>
          <p style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--color-primary)' }}>
            0
          </p>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;