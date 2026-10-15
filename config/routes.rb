Rails.application.routes.draw do
  # Devise authentication routes
  devise_for :users,
             path: 'api/v1/users',
             defaults: { format: :json },
             controllers: { sessions: 'users/sessions' }

  namespace :api do
    namespace :v1 do
      # Health check endpoint (no authentication required)
      get 'health', to: 'health#index'
      get 'dashboard/stats', to: 'dashboard#stats'
      
      # Auth endpoints
      get 'auth/profile', to: 'auth#profile'

      # Resource endpoints
      resources :departments
      resources :employees do
        resources :salaries, on: :collection do
          get 'salary_totals_by_department'
          get 'average_salary_by_job_title'
          get 'department_comparison'
          get 'salary_by_currency'
          get 'export_salaries'
          get 'export_employees'
        end
      end
      
      # Direct salaries routes (additional access pattern)
      resources :salaries, param: :id
      
      resources :locations
      resources :reports, only: [] do
        collection do
          get :salary_totals_by_department
          get :average_salary_by_job_title
          get :department_comparison
          get :salary_by_currency
          get :export_salaries
          get :export_employees
        end
      end
    end
  end

  # Health check route
  get "up", to: "rails/health#up"
end
