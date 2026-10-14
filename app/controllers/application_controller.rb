# Base controller for the application
# Handles shared logic across all controllers including authentication
class ApplicationController < ActionController::API
  # PaperTrail configuration - track user who made changes
  # PaperTrail automatically tracks changes when models have has_paper_trail
  # The whodunnit is set via the paper_trail_whodunnit method
  PaperTrail::VERSION # Ensure PaperTrail is loaded

  # Authentication helpers available to all controllers
  private

  # Check if a user is authenticated via Devise session
  # Returns the current user or nil
  def authenticate_user!
    return if user_signed_in?

    render json: { error: 'You need to sign in first' }, status: :unauthorized
  end

  # PaperTrail callback - set the whodunnit (who made the change)
  def paper_trail_whodunnit
    current_user&.email || 'anonymous'
  end
end
