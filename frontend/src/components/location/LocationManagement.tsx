import React, { useState } from 'react';
import { useLocations, useLocationMutation } from '../../hooks/useLocationData';
import { Location } from '../../services/locationService';
import { usePagination } from '../../hooks/usePagination';
import Pagination from '../common/Pagination';

const LocationManagement: React.FC = () => {
  const [deleteConfirmId, setDeleteConfirmId] = useState<number | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [editingLocation, setEditingLocation] = useState<Location | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    address: '',
    city: '',
    state: '',
    zip_code: '',
    country: 'USA',
    latitude: '',
    longitude: '',
  });
  const { locations, loading, error, refetch: refetchLocations } = useLocations();
  const { createLocation, updateLocation, deleteLocation, loading: mutationLoading, error: mutationError } = useLocationMutation();
  const pagination = usePagination(locations);

  const handleDelete = async (id: number) => {
    if (deleteConfirmId !== id) {
      setDeleteConfirmId(id);
      return;
    }
    try {
      await deleteLocation(id);
      setDeleteConfirmId(null);
      refetchLocations();
    } catch (err) {
      // Error handled in hook
    }
  };

  const handleEdit = (loc: Location) => {
    setEditingLocation(loc);
    setFormData({
      name: loc.name || '',
      address: loc.address || '',
      city: loc.city || '',
      state: loc.state || '',
      zip_code: loc.zip_code || '',
      country: loc.country || 'USA',
      latitude: loc.latitude?.toString() || '',
      longitude: loc.longitude?.toString() || '',
    });
    setShowForm(true);
  };

  const handleCreate = () => {
    setEditingLocation(null);
    setFormData({
      name: '',
      address: '',
      city: '',
      state: '',
      zip_code: '',
      country: 'USA',
      latitude: '',
      longitude: '',
    });
    setShowForm(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const locationData: Partial<Location> = {
        name: formData.name,
        address: formData.address || null,
        city: formData.city || null,
        state: formData.state || null,
        zip_code: formData.zip_code || null,
        country: formData.country,
      };
      if (formData.latitude) locationData.latitude = parseFloat(formData.latitude);
      if (formData.longitude) locationData.longitude = parseFloat(formData.longitude);
      if (editingLocation) {
        await updateLocation(editingLocation.id, locationData);
      } else {
        await createLocation(locationData);
      }
      setShowForm(false);
      setEditingLocation(null);
      refetchLocations();
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
        <h1 style={{ color: 'var(--color-text-primary)' }}>Locations</h1>
        <button className="btn btn-primary" onClick={handleCreate}>
          Add Location
        </button>
      </div>

      {showForm && (
        <div className="card" style={{ marginBottom: '1rem' }}>
          <h2 style={{ color: 'var(--color-text-primary)', marginBottom: '1rem' }}>
            {editingLocation ? 'Edit Location' : 'New Location'}
          </h2>
          {mutationError && (
            <div style={{ backgroundColor: 'var(--color-error-bg)', color: 'var(--color-error)', padding: '0.75rem', borderRadius: '0.375rem', marginBottom: '1rem' }}>
              {mutationError}
            </div>
          )}
          <form onSubmit={handleSubmit}>
            <div>
              <label htmlFor="name" style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}>Name *</label>
              <input id="name" type="text" name="name" value={formData.name} onChange={(e) => setFormData({ ...formData, name: e.target.value })} className="input" placeholder="Enter location name" required />
            </div>
            <div style={{ marginTop: '1rem' }}>
              <label htmlFor="address" style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}>Address</label>
              <input id="address" type="text" name="address" value={formData.address} onChange={(e) => setFormData({ ...formData, address: e.target.value })} className="input" placeholder="Enter address" />
            </div>
            <div style={{ marginTop: '1rem' }}>
              <label htmlFor="city" style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}>City</label>
              <input id="city" type="text" name="city" value={formData.city} onChange={(e) => setFormData({ ...formData, city: e.target.value })} className="input" placeholder="Enter city" />
            </div>
            <div style={{ marginTop: '1rem' }}>
              <label htmlFor="state" style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}>State</label>
              <input id="state" type="text" name="state" value={formData.state} onChange={(e) => setFormData({ ...formData, state: e.target.value })} className="input" placeholder="Enter state" />
            </div>
            <div style={{ marginTop: '1rem' }}>
              <label htmlFor="zip_code" style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}>ZIP Code</label>
              <input id="zip_code" type="text" name="zip_code" value={formData.zip_code} onChange={(e) => setFormData({ ...formData, zip_code: e.target.value })} className="input" placeholder="Enter ZIP code" />
            </div>
            <div style={{ marginTop: '1rem' }}>
              <label htmlFor="country" style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}>Country *</label>
              <select id="country" name="country" value={formData.country} onChange={(e) => setFormData({ ...formData, country: e.target.value })} className="input" required>
                <option value="USA">USA</option>
                <option value="Canada">Canada</option>
                <option value="Mexico">Mexico</option>
                <option value="UK">UK</option>
              </select>
            </div>
            <div style={{ marginTop: '1rem' }}>
              <label htmlFor="latitude" style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}>Latitude</label>
              <input id="latitude" type="number" name="latitude" value={formData.latitude} onChange={(e) => setFormData({ ...formData, latitude: e.target.value })} className="input" placeholder="Enter latitude" step="0.000001" />
            </div>
            <div style={{ marginTop: '1rem' }}>
              <label htmlFor="longitude" style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--color-text-secondary)' }}>Longitude</label>
              <input id="longitude" type="number" name="longitude" value={formData.longitude} onChange={(e) => setFormData({ ...formData, longitude: e.target.value })} className="input" placeholder="Enter longitude" step="0.000001" />
            </div>
            <div style={{ marginTop: '1.5rem', display: 'flex', gap: '0.75rem' }}>
              <button type="submit" className="btn btn-primary" disabled={mutationLoading}>
                {mutationLoading ? 'Saving...' : (editingLocation ? 'Update' : 'Create')}
              </button>
              <button type="button" className="btn btn-secondary" onClick={() => setShowForm(false)} disabled={mutationLoading}>Cancel</button>
            </div>
          </form>
        </div>
      )}

      <div className="card">
        <table>
          <thead>
            <tr><th>ID</th><th>Name</th><th>City</th><th>State</th><th>Country</th><th>Actions</th></tr>
          </thead>
          <tbody>
            {pagination.items.map((loc) => (
              <tr key={loc.id}>
                <td>{loc.id}</td>
                <td>{loc.name}</td>
                <td>{loc.city || 'N/A'}</td>
                <td>{loc.state || 'N/A'}</td>
                <td>{loc.country}</td>
                <td>
                  <div style={{ display: 'flex', gap: '0.5rem' }}>
                    <button className="btn btn-secondary" style={{ padding: '0.25rem 0.75rem', fontSize: '0.75rem' }} onClick={() => handleEdit(loc)}>Edit</button>
                    <button className="btn btn-danger" style={{ padding: '0.25rem 0.75rem', fontSize: '0.75rem' }} onClick={() => handleDelete(loc.id)}>
                      {deleteConfirmId === loc.id ? 'Confirm?' : 'Delete'}
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

export default LocationManagement;