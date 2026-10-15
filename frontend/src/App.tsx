import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Layout from './components/layout/Layout';
import Dashboard from './pages/Dashboard';
import Login from './pages/Login';
import EmployeeList from './components/employee/EmployeeList';
import EmployeeDetail from './components/employee/EmployeeDetail';
import EmployeeForm from './components/employee/EmployeeForm';
import SalaryForm from './components/employee/SalaryForm';
import DepartmentManagement from './components/department/DepartmentManagement';
import LocationManagement from './components/location/LocationManagement';
import ReportsDashboard from './components/reports/ReportsDashboard';
import { ThemeProvider } from './contexts/ThemeContext';
import { AuthProvider } from './contexts/AuthContext';

function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route element={<Layout />}>
            <Route path="/" element={<Dashboard />} />
            <Route path="/employees" element={<EmployeeList />} />
            <Route path="/employees/new" element={<EmployeeForm />} />
            <Route path="/employees/:id" element={<EmployeeDetail />} />
            <Route path="/employees/:id/edit" element={<EmployeeForm />} />
            <Route path="/employees/:id/salary/new" element={<SalaryForm />} />
            <Route path="/employees/:id/salary/:salaryId/edit" element={<SalaryForm />} />
            <Route path="/departments" element={<DepartmentManagement />} />
            <Route path="/locations" element={<LocationManagement />} />
            <Route path="/reports" element={<ReportsDashboard />} />
          </Route>
        </Routes>
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;