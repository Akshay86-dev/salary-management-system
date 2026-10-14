# Base controller for the application
# Handles shared logic across all controllers including authentication
class ApplicationController < ActionController::API
  # Authentication helpers available to all controllers
  private

  # Check if a user is authenticated via Devise session
  # Returns the current user or nil
  def authenticate_user!
    return if user_signed_in?

    render json: { error: 'You need to sign in first' }, status: :unauthorized
  end
end
