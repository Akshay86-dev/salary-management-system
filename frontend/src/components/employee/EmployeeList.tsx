import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useDepartments, useEmployees, useEmployeeMutation } from '../../hooks/useEmployeeData';
import { locationService } from '../../services/locationService';
import { usePagination } from '../../hooks/usePagination';
import Pagination from '../common/Pagination';

const EmployeeList: React.FC = () => {
  const [deleteConfirmId, setDeleteConfirmId] = useState<number | null>(null);
  const [searchInput, setSearchInput] = useState('');
  const [query, setQuery] = useState('');
  const [country, setCountry] = useState('');
  const [departmentId, setDepartmentId] = useState('');
  const [status, setStatus] = useState<'all' | 'active' | 'inactive'>('active');
  const [countries, setCountries] = useState<string[]>([]);
  const [countryError, setCountryError] = useState<string | null>(null);
  const { employees, loading, error, refetch } = useEmployees({ query, country, departmentId, status });
  const { departments, error: departmentsError } = useDepartments();
  const { deleteEmployee, loading: deleteLoading } = useEmployeeMutation();
  const navigate = useNavigate();
  const pagination = usePagination(employees);

  useEffect(() => {
    const timeout = window.setTimeout(() => setQuery(searchInput.trim()), 300);
    return () => window.clearTimeout(timeout);
  }, [searchInput]);

  useEffect(() => {
    pagination.setPage(1);
  }, [query, country, departmentId, status]);

  useEffect(() => {
    const fetchCountries = async () => {
      try {
        const response = await locationService.getAll();
        const values = (response.data || [])
          .map((location: { attributes?: { country?: string } }) => location.attributes?.country)
          .filter((value: string | undefined): value is string => Boolean(value));
        setCountries([...new Set(values)].sort());
      } catch (err: any) {
        setCountryError(err.response?.data?.error || err.message || 'Failed to load country filters');
      }
    };

    fetchCountries();
  }, []);

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
        <div>
          <h1 style={{ color: 'var(--color-text-primary)' }}>Employees</h1>
          <p style={{ color: 'var(--color-text-secondary)' }}>
            {employees.length.toLocaleString()} employees found
          </p>
        </div>
        <button
          className="btn btn-primary"
          onClick={() => navigate('/employees/new')}
        >
          Add Employee
        </button>
      </div>
      
      <div className="card" style={{ marginBottom: '1rem' }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'minmax(220px, 2fr) repeat(3, minmax(130px, 1fr))', gap: '0.75rem' }}>
          <div>
            <label htmlFor="employee-search" style={{ display: 'block', marginBottom: '0.4rem', color: 'var(--color-text-secondary)' }}>
              Search
            </label>
            <input
              id="employee-search"
              type="search"
              className="input"
              placeholder="Name, email, employee ID or job title"
              value={searchInput}
              onChange={(event) => setSearchInput(event.target.value)}
            />
          </div>
          <div>
            <label htmlFor="employee-country" style={{ display: 'block', marginBottom: '0.4rem', color: 'var(--color-text-secondary)' }}>
              Country
            </label>
            <select id="employee-country" className="input" value={country} onChange={(event) => setCountry(event.target.value)}>
              <option value="">All</option>
              {countries.map((countryName) => <option key={countryName} value={countryName}>{countryName}</option>)}
            </select>
          </div>
          <div>
            <label htmlFor="employee-department" style={{ display: 'block', marginBottom: '0.4rem', color: 'var(--color-text-secondary)' }}>
              Department
            </label>
            <select id="employee-department" className="input" value={departmentId} onChange={(event) => setDepartmentId(event.target.value)}>
              <option value="">All</option>
              {departments.map((department) => <option key={department.id} value={department.id}>{department.name}</option>)}
            </select>
          </div>
          <div>
            <label htmlFor="employee-status" style={{ display: 'block', marginBottom: '0.4rem', color: 'var(--color-text-secondary)' }}>
              Status
            </label>
            <select
              id="employee-status"
              className="input"
              value={status}
              onChange={(event) => setStatus(event.target.value as 'all' | 'active' | 'inactive')}
            >
              <option value="all">All</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>
        </div>
        {(countryError || departmentsError) && (
          <p role="alert" style={{ color: 'var(--color-error)', marginTop: '0.75rem' }}>
            {countryError || departmentsError}
          </p>
        )}
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
            {pagination.items.length === 0 ? (
              <tr>
                <td colSpan={8} style={{ textAlign: 'center', color: 'var(--color-text-secondary)', padding: '1.5rem' }}>
                  No employees match these filters.
                </td>
              </tr>
            ) : (
              pagination.items.map((employee: any) => (
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
              ))
            )}
          </tbody>
        </table>
        <Pagination
          page={pagination.page}
          pageSize={pagination.pageSize}
          totalItems={pagination.totalItems}
          totalPages={pagination.totalPages}
          startItem={pagination.startItem}
          endItem={pagination.endItem}
          onPageChange={pagination.setPage}
          onPageSizeChange={pagination.setPageSize}
        />
      </div>
    </div>
  );
};

export default EmployeeList;