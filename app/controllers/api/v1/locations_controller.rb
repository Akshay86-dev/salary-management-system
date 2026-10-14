# frozen_string_literal: true

# API v1 Locations Controller
# Provides CRUD endpoints for location management
class Api::V1::LocationsController < Api::V1::BaseController
  # GET /api/v1/locations
  # List all locations with optional filtering
  def index
    locations = Location.ordered
    locations = Location.by_state(params[:state]) if params[:state].present?
    locations = Location.search(params[:query]) if params[:query].present?

    render json: LocationSerializer.new(locations, is_collection: true)
  end

  # GET /api/v1/locations/:id
  # Show a specific location
  def show
    location = Location.find(params[:id])
    render json: LocationSerializer.new(location)
  end

  # POST /api/v1/locations
  # Create a new location
  def create
    location = Location.new(location_params)

    if location.save
      render json: LocationSerializer.new(location), status: :created
    else
      render json: { errors: location.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/locations/:id
  # Update a location
  def update
    location = Location.find(params[:id])

    if location.update(location_params)
      render json: LocationSerializer.new(location)
    else
      render json: { errors: location.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/locations/:id
  # Delete a location
  def destroy
    location = Location.find(params[:id])
    location.destroy!

    render json: null, status: :no_content
  end

  private

  # Strong parameters for location attributes
  def location_params
    params.require(:data).require(:attributes).permit(
      :name, :address, :city, :state, :zip_code, :country, :latitude, :longitude
    )
  end
end
