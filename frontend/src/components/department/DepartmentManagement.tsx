import React, { useState } from 'react';
import { useDepartments, useDepartmentMutation } from '../../hooks/useDepartmentData';
import { Department } from '../../services/departmentService';
import { usePagination } from '../../hooks/usePagination';
import Pagination from '../common/Pagination';

const DepartmentManagement: React.FC = () => {
  const [deleteConfirmId, setDeleteConfirmId] = useState<number | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [editingDept, setEditingDept] = useState<Department | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    budget: '',
    manager_id: '',
  });
  const { departments, loading, error, refetch: refetchDepartments } = useDepartments();
  const { createDepartment, updateDepartment, deleteDepartment, loading: mutationLoading, error: mutationError } = useDepartmentMutation();
  const pagination = usePagination(departments);

  const handleDelete = async (id: number) => {
    if (deleteConfirmId !== id) {
      setDeleteConfirmId(id);
      return;
    }

    try {
      await deleteDepartment(id);
      setDeleteConfirmId(null);
      refetchDepartments();
    } catch (err) {
      // Error handled in hook
    }
  };

  const handleEdit = (dept: Department) => {
    setEditingDept(dept);
    setFormData({
      name: dept.name || '',
      budget: dept.budget?.toString() || '',
      manager_id: dept.manager_id?.toString() || '',
    });
    setShowForm(true);
  };

  const handleCreate = () => {
    setEditingDept(null);
    setFormData({
      name: '',
      budget: '',
      manager_id: '',
    });
    setShowForm(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const deptData: Partial<Department> = {
      name: formData.name,
    };

    if (formData.budget) {
      deptData.budget = parseFloat(formData.budget);
    }
    if (formData.manager_id) {
      deptData.manager_id = parseInt(formData.manager_id, 10);
    }

    try {
      if (editingDept) {
        await updateDepartment(editingDept.id, deptData);
      } else {
        await createDepartment(deptData);
      }
      setShowForm(false);
      setEditingDept(null);
      refetchDepartments();
    } catch (err) {
      // Error handled in hook
    }
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
        <h1 style={{ color: 'var(--color-text-primary)' }}>Departments</h1>
        <button className="btn btn-primary" onClick={handleCreate}>
          Add Department
        </button>
      </div>

      {showForm && (
        <div className="card" style={{ marginBottom: '1rem' }}>
          <h2 style={{ color: 'var(--color-text-primary)', marginBottom: '1rem' }}>
            {editingDept ? 'Edit Department' : 'New Department'}
          </h2>
          {mutationError && (
            <div style={{ backgroundColor: 'var(--color-error-bg)', color: 'var(--color-error)', padding: '0.75rem', borderRadius: '0.375rem', marginBottom: '1rem' }}>
              {mutationError}
            </div>
          )}
          <form onSubmit={handleSubmit}>
            <div>
              <label htmlFor="name" style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}>Name</label>
              <input id="name" type="text" name="name" value={formData.name} onChange={(e) => setFormData({ ...formData, name: e.target.value })} className="input" placeholder="Enter department name" required />
            </div>
            <div style={{ marginTop: '1rem' }}>
              <label htmlFor="budget" style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}>Budget</label>
              <input id="budget" type="number" name="budget" value={formData.budget} onChange={(e) => setFormData({ ...formData, budget: e.target.value })} className="input" placeholder="Enter budget" min="0" step="0.01" />
            </div>
            <div style={{ marginTop: '1rem' }}>
              <label htmlFor="manager_id" style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}>Manager ID</label>
              <input id="manager_id" type="number" name="manager_id" value={formData.manager_id} onChange={(e) => setFormData({ ...formData, manager_id: e.target.value })} className="input" placeholder="Enter manager ID" min="0" />
            </div>
            <div style={{ marginTop: '1.5rem', display: 'flex', gap: '0.75rem' }}>
              <button type="submit" className="btn btn-primary" disabled={mutationLoading}>
                {mutationLoading ? 'Saving...' : (editingDept ? 'Update' : 'Create')}
              </button>
              <button type="button" className="btn btn-secondary" onClick={() => setShowForm(false)} disabled={mutationLoading}>Cancel</button>
            </div>
          </form>
        </div>
      )}

      <div className="card">
        <table>
          <thead>
            <tr><th>ID</th><th>Name</th><th>Budget</th><th>Manager ID</th><th>Actions</th></tr>
          </thead>
          <tbody>
            {pagination.items.map((dept) => (
              <tr key={dept.id}>
                <td>{dept.id}</td>
                <td>{dept.name}</td>
                <td>${dept.budget?.toLocaleString() || 'N/A'}</td>
                <td>{dept.manager_id || 'N/A'}</td>
                <td>
                  <div style={{ display: 'flex', gap: '0.5rem' }}>
                    <button className="btn btn-secondary" style={{ padding: '0.25rem 0.75rem', fontSize: '0.75rem' }} onClick={() => handleEdit(dept)}>Edit</button>
                    <button className="btn btn-danger" style={{ padding: '0.25rem 0.75rem', fontSize: '0.75rem' }} onClick={() => handleDelete(dept.id)}>
                      {deleteConfirmId === dept.id ? 'Confirm?' : 'Delete'}
                    </button>
                  </div>
                </td>
              </tr>
            ))}
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

export default DepartmentManagement;
