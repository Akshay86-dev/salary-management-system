import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useSalary, useSalaryMutation, useEmployeeOptions } from '../../hooks/useSalaryData';
import { Salary } from '../../services/salaryService';

const SALARY_TYPES = [
  { value: 0, label: 'Base' },
  { value: 1, label: 'Bonus' },
  { value: 2, label: 'Commission' },
  { value: 3, label: 'Equity' },
];

const SalaryForm: React.FC = () => {
  const { id } = useParams<{ id?: string }>();
  const salaryId = id ? parseInt(id, 10) : null;
  const isEditMode = !!salaryId;
  const navigate = useNavigate();

  const { salary: existingSalary, loading: loadingSalary } = useSalary(salaryId || 0);
  const { employees, loading: loadingEmployees } = useEmployeeOptions();
  const { createSalary, updateSalary, loading, error: mutationError } = useSalaryMutation();

  const [formData, setFormData] = useState({
    employee_id: '',
    amount: '',
    currency: 'USD',
    salary_type: '0',
    effective_date: '',
    is_current: 'true',
  });
  const [formError, setFormError] = useState('');

  useEffect(() => {
    if (isEditMode && existingSalary) {
      setFormData({
        employee_id: existingSalary.employee_id?.toString() || '',
        amount: existingSalary.amount?.toString() || '',
        currency: existingSalary.currency || 'USD',
        salary_type: existingSalary.salary_type?.toString() || '0',
        effective_date: existingSalary.effective_date ? existingSalary.effective_date.split('T')[0] : '',
        is_current: existingSalary.is_current ? 'true' : 'false',
      });
    }
  }, [isEditMode, existingSalary]);

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
      const salaryData: Partial<Salary> = {
        employee_id: parseInt(formData.employee_id, 10),
        amount: parseFloat(formData.amount),
        currency: formData.currency,
        salary_type: parseInt(formData.salary_type, 10),
        effective_date: formData.effective_date,
        is_current: formData.is_current === 'true',
      };

      if (isEditMode && salaryId) {
        await updateSalary(salaryId, salaryData);
      } else {
        await createSalary(salaryData);
      }

      navigate('/employees');
    } catch (err: any) {
      setFormError(err.response?.data?.errors?.[0] || err.message || 'Failed to save salary');
    }
  };

  if (loadingSalary && isEditMode) {
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
          {isEditMode ? 'Edit Salary' : 'Add New Salary'}
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

        <form onSubmit={handleSubmit}>
          <div>
            <label
              htmlFor="employee_id"
              style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}
            >
              Employee
            </label>
            <select
              id="employee_id"
              name="employee_id"
              value={formData.employee_id}
              onChange={handleChange}
              className="input"
              disabled={loadingEmployees || loading}
              required
            >
              <option value="">Select an employee</option>
              {employees.map((emp: any) => (
                <option key={emp.id} value={emp.id}>
                  {emp.first_name} {emp.last_name} ({emp.email})
                </option>
              ))}
            </select>
          </div>

          <div style={{ marginTop: '1rem' }}>
            <label
              htmlFor="amount"
              style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}
            >
              Amount
            </label>
            <input
              id="amount"
              type="number"
              name="amount"
              value={formData.amount}
              onChange={handleChange}
              className="input"
              placeholder="Enter amount"
              min="0"
              step="0.01"
              required
            />
          </div>

          <div style={{ marginTop: '1rem' }}>
            <label
              htmlFor="currency"
              style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}
            >
              Currency
            </label>
            <select
              id="currency"
              name="currency"
              value={formData.currency}
              onChange={handleChange}
              className="input"
              disabled={loading}
            >
              <option value="USD">USD - US Dollar</option>
              <option value="CAD">CAD - Canadian Dollar</option>
              <option value="MXN">MXN - Mexican Peso</option>
              <option value="GBP">GBP - British Pound</option>
            </select>
          </div>

          <div style={{ marginTop: '1rem' }}>
            <label
              htmlFor="salary_type"
              style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}
            >
              Salary Type
            </label>
            <select
              id="salary_type"
              name="salary_type"
              value={formData.salary_type}
              onChange={handleChange}
              className="input"
              disabled={loading}
            >
              {SALARY_TYPES.map(type => (
                <option key={type.value} value={type.value}>
                  {type.label}
                </option>
              ))}
            </select>
          </div>

          <div style={{ marginTop: '1rem' }}>
            <label
              htmlFor="effective_date"
              style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}
            >
              Effective Date
            </label>
            <input
              id="effective_date"
              type="date"
              name="effective_date"
              value={formData.effective_date}
              onChange={handleChange}
              className="input"
            />
          </div>

          <div style={{ marginTop: '1rem' }}>
            <label
              htmlFor="is_current"
              style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}
            >
              Current Salary
            </label>
            <select
              id="is_current"
              name="is_current"
              value={formData.is_current}
              onChange={handleChange}
              className="input"
              disabled={loading}
            >
              <option value="true">Yes</option>
              <option value="false">No</option>
            </select>
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
              ) : (isEditMode ? 'Update Salary' : 'Create Salary')}
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

export default SalaryForm;