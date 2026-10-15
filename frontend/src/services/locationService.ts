import apiClient from './api';

// Location interface
export interface Location {
  id: number;
  name: string;
  address: string | null;
  city: string | null;
  state: string | null;
  zip_code: string | null;
  country: string;
  latitude: number | null;
  longitude: number | null;
  full_address: string | null;
  formatted_location: string | null;
  created_at: string;
  updated_at: string;
}

interface JsonApiLocation {
  id: number | string;
  attributes: Omit<Location, 'id'>;
}

export const normalizeLocation = (record: Location | JsonApiLocation): Location => {
  if (!('attributes' in record)) {
    return record;
  }

  return { ...record.attributes, id: Number(record.id) };
};

// Location service
export const locationService = {
  // Fetch all locations
  getAll: async () => {
    const response = await apiClient.get('/locations');
    return response.data;
  },

  // Fetch a single location by ID
  getById: async (id: number) => {
    const response = await apiClient.get(`/locations/${id}`);
    return response.data;
  },

  // Create a new location
  create: async (locationData: Partial<Location>) => {
    const response = await apiClient.post('/locations', { data: { attributes: locationData } });
    return response.data;
  },

  // Update an existing location
  update: async (id: number, locationData: Partial<Location>) => {
    const response = await apiClient.put(`/locations/${id}`, { data: { attributes: locationData } });
    return response.data;
  },

  // Delete a location
  delete: async (id: number) => {
    const response = await apiClient.delete(`/locations/${id}`);
    return response.data;
  },
};

export default locationService;