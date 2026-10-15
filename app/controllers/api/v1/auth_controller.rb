# frozen_string_literal: true

# Authentication controller for API v1
# Uses Devise for sign_in/sign_out, provides profile endpoint
class Api::V1::AuthController < Api::V1::BaseController
  before_action :authenticate_user!, only: :profile

  # GET /api/v1/auth/profile
  # Get the current user's profile
  # @return [JSON] current user data
  def profile
    render json: {
      data: {
        id: current_user.id,
        type: "user",
        attributes: user_profile_attributes(current_user)
      }
    }
  end
end
