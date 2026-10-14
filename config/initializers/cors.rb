# frozen_string_literal: true

# Configure CORS for React frontend to communicate with Rails API
# Using session/cookie-based authentication, so credentials must be enabled

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # In development, allow localhost frontend
    # In production, set CORS_ORIGINS env var to your React app's origin(s)
    origins = if Rails.env.production?
                ENV.fetch('CORS_ORIGINS', 'https://example.com').split(',')
              else
                ['http://localhost:3000', 'http://127.0.0.1:3000']
              end

    origins(*origins)

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end