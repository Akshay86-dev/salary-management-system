import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useEmployee, useEmployeeMutation, useDepartments } from '../../hooks/useEmployeeData';
import { useLocations } from '../../hooks/useLocationData';
import { errorMessage } from '../../services/errorMessage';

const EmployeeForm: React.FC = () => {
  const { id } = useParams<{ id?: string }>();
  const employeeId = id ? parseInt(id, 10) : null;
  const isEditMode = !!employeeId;
  const navigate = useNavigate();
  
  const { employee: existingEmployee, loading: loadingEmployee } = useEmployee(employeeId || 0);
  const { departments, loading: loadingDepartments } = useDepartments();
  const { locations, loading: loadingLocations, error: locationsError } = useLocations();
  const { createEmployee, updateEmployee, loading, error: mutationError } = useEmployeeMutation();

  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    email: '',
    job_title: '',
    department_id: '',
    location_id: '',
    hire_date: '',
    salary: '',
  });
  const [selectedCountry, setSelectedCountry] = useState('');
  const [formError, setFormError] = useState('');

  // Populate form if editing
  useEffect(() => {
    if (isEditMode && existingEmployee) {
      setFormData({
        first_name: existingEmployee.first_name || '',
        last_name: existingEmployee.last_name || '',
        email: existingEmployee.email || '',
        job_title: existingEmployee.job_title || '',
        department_id: existingEmployee.department_id?.toString() || '',
        location_id: existingEmployee.location_id?.toString() || '',
        hire_date: existingEmployee.hire_date ? existingEmployee.hire_date.split('T')[0] : '',
        salary: existingEmployee.salary?.toString() || '',
      });
      const employeeLocation = locations.find((location) => location.id === existingEmployee.location_id);
      if (employeeLocation) {
        setSelectedCountry(employeeLocation.country);
      }
    }
  }, [isEditMode, existingEmployee, locations]);

  const countries = [...new Set(locations.map((location) => location.country))].sort();
  const filteredLocations = locations.filter((location) => location.country === selectedCountry);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
        setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError('');

    try {
      const employeeData = {
        ...formData,
        department_id: formData.department_id ? parseInt(formData.department_id, 10) : undefined,
        location_id: formData.location_id ? parseInt(formData.location_id, 10) : undefined,
        hire_date: formData.hire_date || undefined,
        salary: formData.salary ? parseFloat(formData.salary) : undefined,
      };

      if (isEditMode && employeeId) {
        await updateEmployee(employeeId, employeeData);
      } else {
        await createEmployee(employeeData);
      }
      
      navigate('/employees');
    } catch (err) {
      setFormError(errorMessage(err, 'Failed to save employee'));
    }
  };

  if (loadingEmployee && isEditMode) {
    return (
      <div className="flex-center" style={{ padding: '2rem' }}>
        <span className="loader"></span>
      </div>
    );
  }

  return (
    <div>
      <div className="flex" style={{ marginBottom: '1rem' }}>
        <h1 style={{ color: 'var(--color-text-primary)' }}>
          {isEditMode ? 'Edit Employee' : 'Add New Employee'}
        </h1>
        <button 
          className="btn btn-secondary"
          onClick={() => navigate('/employees')}
        >
          Back to List
        </button>
      </div>

      <div className="card">
        {(formError || mutationError) && (
          <div 
            style={{ 
              backgroundColor: 'var(--color-error-bg)', 
              color: 'var(--color-error)',
              padding: '0.75rem',
              borderRadius: '0.375rem',
              marginBottom: '1rem'
            }}
          >
            {formError || mutationError}
          </div>
        )}
        {locationsError && (
          <div role="alert" style={{ color: 'var(--color-error)', marginBottom: '1rem' }}>
            {locationsError}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
            <div>
              <label 
                htmlFor="first_name" 
                style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}
              >
                First Name
              </label>
              <input
                id="first_name"
                type="text"
                name="first_name"
                value={formData.first_name}
                onChange={handleChange}
                className="input"
                placeholder="Enter first name"
                required
              />
            </div>

            <div>
              <label 
                htmlFor="last_name" 
                style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}
              >
                Last Name
              </label>
              <input
                id="last_name"
                type="text"
                name="last_name"
                value={formData.last_name}
                onChange={handleChange}
                className="input"
                placeholder="Enter last name"
                                required
              />
            </div>
          </div>

          <div style={{ marginTop: '1rem' }}>
            <label
              htmlFor="country"
              style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}
            >
              Country
            </label>
            <select
              id="country"
              name="country"
              value={selectedCountry}
              onChange={(event) => {
                setSelectedCountry(event.target.value);
                setFormData((previous) => ({ ...previous, location_id: '' }));
              }}
              className="input"
              disabled={loadingLocations}
              required
            >
              <option value="">Select a country</option>
              {countries.map((country) => (
                <option key={country} value={country}>{country}</option>
              ))}
            </select>
          </div>

          <div style={{ marginTop: '1rem' }}>
            <label 
              htmlFor="email" 
              style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}
            >
              Email
            </label>
            <input
              id="email"
              type="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              className="input"
              placeholder="Enter email"
              required
            />
          </div>

          <div style={{ marginTop: '1rem' }}>
            <label 
              htmlFor="job_title" 
              style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}
            >
              Job Title
            </label>
            <input
              id="job_title"
              type="text"
              name="job_title"
              value={formData.job_title}
              onChange={handleChange}
              className="input"
              placeholder="Enter job title"
              required
            />
          </div>

          <div style={{ marginTop: '1rem' }}>
            <label 
              htmlFor="department_id" 
              style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}
            >
              Department
            </label>
            <select
              id="department_id"
              name="department_id"
              value={formData.department_id}
              onChange={handleChange}
              className="input"
              disabled={loadingDepartments}
              required
            >
              <option value="">Select a department</option>
              {departments.map((dept) => (
                <option key={dept.id} value={dept.id}>
                  {dept.name}
                </option>
              ))}
            </select>
          </div>

          <div style={{ marginTop: '1rem' }}>
            <label
              htmlFor="location_id"
              style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}
            >
              Location
            </label>
            <select
              id="location_id"
              name="location_id"
              value={formData.location_id}
              onChange={handleChange}
              className="input"
              disabled={loadingLocations || !selectedCountry}
              required
            >
              <option value="">Select a location</option>
              {filteredLocations.map((location) => (
                <option key={location.id} value={location.id}>{location.name}</option>
              ))}
            </select>
          </div>

          <div style={{ marginTop: '1rem' }}>
            <label 
              htmlFor="hire_date" 
              style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}
            >
              Hire Date
            </label>
            <input
              id="hire_date"
              type="date"
              name="hire_date"
              value={formData.hire_date}
              onChange={handleChange}
              className="input"
              required
            />
          </div>

          <div style={{ marginTop: '1rem' }}>
            <label 
              htmlFor="salary" 
              style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}
            >
              Salary
            </label>
            <input
              id="salary"
              type="number"
              name="salary"
              value={formData.salary}
              onChange={handleChange}
              className="input"
              placeholder="Enter salary"
              min="0"
              step="0.01"
            />
          </div>

          <div style={{ marginTop: '1.5rem', display: 'flex', gap: '0.75rem' }}>
            <button 
              type="submit" 
              className="btn btn-primary"
              disabled={loading}
            >
              {loading ? (
                <span style={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <span className="loader" style={{ width: '1rem', height: '1rem', marginRight: '0.5rem' }}></span>
                  {isEditMode ? 'Updating...' : 'Creating...'}
                </span>
              ) : (isEditMode ? 'Update Employee' : 'Create Employee')}
            </button>
            <button 
              type="button" 
              className="btn btn-secondary"
              onClick={() => navigate('/employees')}
              disabled={loading}
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default EmployeeForm;