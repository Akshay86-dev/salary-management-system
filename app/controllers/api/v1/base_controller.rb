# frozen_string_literal: true

# Base controller for API v1 endpoints
# All API v1 controllers should inherit from this controller
# Provides authentication and common response helpers
class Api::V1::BaseController < ApplicationController
  # All API v1 endpoints require authentication by default
  before_action :authenticate_user!

  # Health check endpoint
  def health
    render json: {
      status: 'ok',
      timestamp: Time.current.iso8601
    }
  end

  private

  # Render a standardized JSON error response
  # @param message [String] the error message
  # @param status [Symbol/Symbol] the HTTP status code
  def render_error(message, status: :bad_request)
    render json: { error: message }, status: status
  end

  # Render a standardized JSON success response
  # @param data [Hash/Array] the data to render
  # @param meta [Hash] optional metadata for pagination, etc.
  def render_success(data = {}, meta = {})
    response = { data: data }
    response[:meta] = meta unless meta.empty?
    render json: response, status: :ok
  end
end