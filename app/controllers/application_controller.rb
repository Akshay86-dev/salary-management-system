# Base controller for the application
# Handles shared logic across all controllers including authentication
class ApplicationController < ActionController::API
  # Include Devise helpers for JWT authentication
  include Devise::Controllers::Helpers

  # PaperTrail configuration - track user who made changes
  # PaperTrail automatically tracks changes when models have has_paper_trail
  # The whodunnit is set via the paper_trail_whodunnit method
  PaperTrail::VERSION # Ensure PaperTrail is loaded

  # PaperTrail callback - set the whodunnit (who made the change)
  def paper_trail_whodunnit
    current_user&.email || "anonymous"
  end

  private

  def user_profile_attributes(user)
    {
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      role: user.role.upcase
    }
  end
end
