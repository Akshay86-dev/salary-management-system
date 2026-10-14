Rails.application.routes.draw do
  # Devise authentication routes for session-based auth
  devise_for :users, defaults: { format: :json }

  namespace :api do
    namespace :v1 do
      # Routes will be added here as controllers are created
    end
  end

  # Health check route
  get "up", to: "rails/health#up"
end
