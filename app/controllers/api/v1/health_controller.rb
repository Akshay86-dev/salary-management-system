# frozen_string_literal: true

# Health check controller for API endpoints (no authentication required)
class Api::V1::HealthController < ApplicationController
  def index
    render json: {
      status: 'ok',
      timestamp: Time.current.iso8601,
      database: 'connected',
      version: '1.0.0'
    }
  end
end
