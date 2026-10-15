import { useState, useEffect, useCallback } from 'react';
import locationService, { Location } from '../services/locationService';

// Custom hook for fetching all locations
export const useLocations = () => {
  const [locations, setLocations] = useState<Location[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchLocations = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await locationService.getAll();
      setLocations(data.data || data.locations || []);
    } catch (err: any) {
      setError(err.response?.data?.errors?.[0] || err.message || 'Failed to fetch locations');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchLocations();
  }, [fetchLocations]);

  return {
    locations,
    loading,
    error,
    refetch: fetchLocations,
  };
};

// Custom hook for fetching a single location
export const useLocation = (id: number) => {
  const [location, setLocation] = useState<Location | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchLocation = useCallback(async () => {
    if (!id) return;

    setLoading(true);
    setError(null);
    try {
      const data = await locationService.getById(id);
      setLocation(data.data || data.location || null);
    } catch (err: any) {
      setError(err.response?.data?.errors?.[0] || err.message || 'Failed to fetch location');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    fetchLocation();
  }, [fetchLocation]);

  return {
    location,
    loading,
    error,
    refetch: fetchLocation,
  };
};

// Custom hook for location mutations
export const useLocationMutation = () => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const createLocation = useCallback(async (data: Partial<Location>) => {
    setLoading(true);
    setError(null);
    try {
      const result = await locationService.create(data);
      return result;
    } catch (err: any) {
      const errorMsg = err.response?.data?.errors?.[0] || err.message || 'Failed to create location';
      setError(errorMsg);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const updateLocation = useCallback(async (id: number, data: Partial<Location>) => {
    setLoading(true);
    setError(null);
    try {
      const result = await locationService.update(id, data);
      return result;
    } catch (err: any) {
      const errorMsg = err.response?.data?.errors?.[0] || err.message || 'Failed to update location';
      setError(errorMsg);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const deleteLocation = useCallback(async (id: number) => {
    setLoading(true);
    setError(null);
    try {
      const result = await locationService.delete(id);
      return result;
    } catch (err: any) {
      const errorMsg = err.response?.data?.errors?.[0] || err.message || 'Failed to delete location';
      setError(errorMsg);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  return {
    loading,
    error,
    createLocation,
    updateLocation,
    deleteLocation,
  };
};