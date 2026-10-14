# frozen_string_literal: true

# Configure CORS for React frontend to communicate with Rails API
# Using JWT bearer token authentication (Authorization header)

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # In development, allow localhost frontend (Vite dev server on 5173)
    # In production, set CORS_ORIGINS env var to your React app's origin(s)
    origins = if Rails.env.production?
                ENV.fetch('CORS_ORIGINS', 'https://example.com').split(',')
              else
                ['http://localhost:3000', 'http://127.0.0.1:3000',
                 'http://localhost:5173', 'http://127.0.0.1:5173']
              end

    origins(*origins)

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization'],
      credentials: false
  end
end