import React from 'react';
import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { useTheme } from '../contexts/ThemeContext';
import { useAuth } from '../contexts/AuthContext';

const Layout: React.FC = () => {
  const { darkMode, toggleTheme } = useTheme();
  const { user, logout, isAuthenticated } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async () => {
    await logout();
    navigate('/login');
  };

  if (!isAuthenticated) {
    return <Outlet />;
  }

  return (
    <div className="layout">
      <nav className="navbar">
        <div className="container" style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div>
            <span style={{ fontSize: '1.25rem', fontWeight: 'bold', color: 'var(--color-text-primary)' }}>
              Salary Management System
            </span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center' }}>
            <NavLink 
              to="/" 
              className="nav-link"
              style={{ 
                padding: '0.5rem 1rem', 
                color: 'var(--color-text-secondary)',
                textDecoration: 'none'
              }}
            >
              Dashboard
            </NavLink>
            <NavLink 
              to="/departments" 
              className="nav-link"
              style={{ 
                padding: '0.5rem 1rem', 
                color: 'var(--color-text-secondary)',
                textDecoration: 'none'
              }}
            >
              Departments
            </NavLink>
            <NavLink 
              to="/employees" 
              className="nav-link"
              style={{ 
                padding: '0.5rem 1rem', 
                color: 'var(--color-text-secondary)',
                textDecoration: 'none'
              }}
            >
              Employees
            </NavLink>
          </div>
          <div style={{ display: 'flex', alignItems: 'center' }}>
            <button 
              onClick={toggleTheme} 
              className="theme-toggle"
              style={{ marginRight: '0.5rem' }}
            >
              {darkMode ? '☀️ Light' : '🌙 Dark'}
            </button>
            <span style={{ color: 'var(--color-text-secondary)', marginRight: '1rem' }}>
              {user?.first_name} {user?.last_name}
            </span>
            <button 
              onClick={handleLogout} 
              className="btn btn-secondary"
            >
              Logout
            </button>
          </div>
        </div>
      </nav>
      <main className="container" style={{ padding: '1.5rem 0' }}>
        <Outlet />
      </main>
    </div>
  );
};

export default Layout;