Rails.application.routes.draw do
  devise_for :users
  # Devise authentication routes for session-based auth
  devise_for :users, defaults: { format: :json }

  namespace :api do
    namespace :v1 do
      # Auth endpoints - using Devise sessions
      # POST /api/v1/auth/sign_in - use POST /users/sign_in instead
      # DELETE /api/v1/auth/sign_out - use DELETE /users/sign_out instead
      # GET /api/v1/auth/profile - custom endpoint to get current user

      get 'auth/profile', to: 'auth#profile'

      # Resource endpoints
      resources :departments
      # resources :employees, :salaries, :locations # To be added later
    end
  end

  # Health check route
  get "up", to: "rails/health#up"
end
