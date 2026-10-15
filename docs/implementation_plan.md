# Implementation Plan

## Overview

Build a Salary Management System for 10,000 employees across multiple countries using Ruby on Rails 8.x with a React.js frontend and PostgreSQL database. The system will replace Excel-based salary management with a web application featuring device-based authentication, automatic audit logging, employee management, salary history tracking, and reporting capabilities. This is a monolithic Rails API serving React frontend.

## Types

### Type Definitions

1. **User Model Fields**:
   - `email: string` (required, unique)
   - `encrypted_password: string` (required)
    - `first_name: string` (required)
   - `last_name: string` (required)

2. **Employee profile fields on User**:
   - `role: string` (enum: `EMPLOYEE`, `HUMAN_RESOURCE`; defaults to `EMPLOYEE`)
   - `employee_id: string` (unique when present; format: "EMP-XXXXX")
   - `job_title: string`
   - `hire_date: date`
   - `department_id: integer` (foreign key)
   - `location_id: integer` (foreign key)
   - `is_active: boolean` (default: true)
   - Employee profiles are identified by a non-null `employee_id`; HR accounts
     may omit employee profile fields. Only HR-role users may authenticate.

3. **Salary Model Fields**:
   - `employee_id: integer` (foreign key)
   - `amount: decimal` (required, precision: 10, scale: 2)
   - `currency: string` (required, default: "USD")
   - `salary_type: integer` (enum: base=0, bonus=1, commission=2, equity=3)
   - `effective_date: date` (required)
   - `is_current: boolean` (default: true)

4. **Department Model Fields**:
   - `name: string` (required, unique)
   - `budget: decimal` (optional)
   - `manager_id: integer` (optional, self-referencing)

5. **Location Model Fields**:
   - `country: string` (required)
   - `city: string` (required)
   - `timezone: string` (required, example: "America/New_York")

## Files

### New Files

1. **`Gemfile`** - Add authentication and API gems
   - `gem 'devise'` - User authentication
   - `gem 'rack-cors'` - CORS handling for React frontend
   - `gem 'active_model_serializers'` or `gem 'jsonapi-serializer'` - JSON API formatting

2. **`config/initializers/devise.rb`** - Devise configuration with session settings

3. **`config/initializers/cors.rb`** - CORS configuration for API access

4. **`app/models/user.rb`** - User model with Devise authentication

5. **`app/models/salary.rb`** - Salary model

7. **`app/models/department.rb`** - Department model

8. **`app/models/location.rb`** - Location model

10. **`app/controllers/api/base_controller.rb`** - Base API controller with authentication

11. **`app/controllers/api/auth_controller.rb`** - Authentication endpoints (login/logout)

12. **`app/controllers/api/v1/employees_controller.rb`** - Employee CRUD endpoints

13. **`app/controllers/api/v1/salaries_controller.rb`** - Salary CRUD endpoints

14. **`app/controllers/api/v1/departments_controller.rb`** - Department CRUD endpoints

15. **`app/controllers/api/v1/locations_controller.rb`** - Location CRUD endpoints

15. **`app/controllers/api/v1/reports_controller.rb`** - Reporting endpoints

16. **Database migrations** (in `db/migrate/`):
   - `devise_create_users.rb`
   - `create_employees.rb` (historical; employee data is migrated to users)
   - `move_employee_data_to_users.rb`
   - `create_salaries.rb`
   - `create_departments.rb`
   - `create_locations.rb`

17. **`db/seeds.rb`** - Updated to seed 10,000 employees with departments, locations, and salaries

20. **`frontend/`** - React application directory
   - `package.json` - React dependencies (axios, react-router-dom, etc.)
   - `src/App.jsx` - Main React component
    - `src/services/api.js` - Axios instance with Devise session config
    - `src/services/api.js` - Axios instance with Devise session config
   - `src/services/authService.js` - Authentication API calls
   - `src/services/employeeService.js` - Employee API calls
   - `src/services/salaryService.js` - Salary API calls
   - `src/services/departmentService.js` - Department API calls
   - `src/services/locationService.js` - Location API calls
   - `src/services/reportService.js` - Report API calls
   - `src/hooks/useApi.js` - Custom hook for API requests
   - `src/hooks/useAuth.js` - Authentication hook
   - `src/hooks/useEmployees.js` - Employee data hook
   - `src/hooks/useSalaries.js` - Salary data hook
   - `src/hooks/useDepartments.js` - Department data hook
   - `src/hooks/useLocations.js` - Location data hook
   - `src/hooks/useReports.js` - Report data hook
   - `src/components/...` - Component files for UI

### Files to Modify

1. **`config/routes.rb`** - Add API namespace and routes

2. **`config/database.yml`** - Update with proper PostgreSQL configuration

3. **`config/application.rb`** - Add CORS configuration, disable CSRF for API

4. **`app/controllers/application_controller.rb`** - Update for API mode

5. **`test/test_helper.rb`** - Add authentication helpers for tests

6. **`config/initializers/new_framework_permissions.rb`** - May need to create for Devise permissions

7. **`Dockerfile`** - Add React build step

8. **`Procfile.dev`** - Update for running both Rails and React dev servers

### Files to Delete

1. Remove Hotwire/Stimulus-related files if migrating fully to React:
   - `app/javascript/controllers/*` (may keep for legacy)
   - `app/helpers/application_helper.rb` (if unused)
       - `app/assets/stylesheets/application.css` (may move to frontend)

## Functions

### New Functions

1. **`Api::V1::EmployeesController#index`**
   - List employees with pagination, filtering, and sorting

3. **`Api::V1::SalariesController#current`**
   - Get current salary for a specific employee

4. **`Api::V1::ReportsController#department_salaries`**
   - Calculate and return salary totals grouped by department

5. **`Api::V1::ReportsController#job_title_averages`**
   - Calculate and return average salaries grouped by job title

6. **`Api::V1::ReportsController#headcount_by_location`**
   - Return employee counts grouped by location

7. **`Api::V1::ReportsController#export`**
   - Generate and return CSV export of employee data

### Modified Functions

1. **`ApplicationController`**
   - Change to inherit from `ActionController::API` instead of `ActionController::Base`
   - Remove `allow_browser` constraint for API mode

2. **`routes.rb` - `Rails.application.routes.draw`**
   - Add namespace for API routes
   - Add authentication routes (login, logout, register)
   - Add resource routes for employees, salaries, departments, locations
   - Add report routes

### Functions to Remove

1. **Hotwire/Stimulus controllers** (if fully migrating to React)
   - `app/javascript/controllers/hello_controller.js`
   - `app/javascript/controllers/index.js`
   - `app/javascript/controllers/application.js`

## Classes

### New Classes

1. **`User < ApplicationRecord`**
   - File: `app/models/user.rb`
   - Includes Devise JWT authentication and the `EMPLOYEE` / `HUMAN_RESOURCE` role enum
   - Stores employee profile fields as well as authentication fields
   - HR roles authenticate; employee roles do not
   - Key profile methods:
    - `full_name` - Returns first_name + last_name
    - `current_salary` - Returns the salary with `is_current: true`
   - Scopes: `employee_records`, `active`, `inactive`, `search`

4. **`Salary < ApplicationRecord`**
   - File: `app/models/salary.rb`
   - Relationships: `belongs_to :employee`, backed by a `User` association
   - Enums: `salary_type` (base, bonus, commission, equity)
   - Key methods:
    - `formatted_amount` - Returns amount with currency symbol
    - `annualized_amount` - Returns annual equivalent if not already annual
   - Scopes: `current`, `by_employee`, `by_type`

5. **`Department < ApplicationRecord`**
   - File: `app/models/department.rb`
   - Relationships: `has_many :employees`, `belongs_to :manager` (optional, self-referencing)
   - Key methods:
    - `headcount` - Returns count of active employees
    - `total_salary_budget` - Returns sum of current base salaries
   - Validations: name presence and uniqueness

6. **`Location < ApplicationRecord`**
   - File: `app/models/location.rb`
   - Relationships: `has_many :employees`
   - Key methods:
    - `display_name` - Returns "City, Country"
    - `headcount` - Count of employees at this location
   - Validations: country, city, timezone presence

### Modified Classes

1. **`ApplicationController < ActionController::API`**
   - File: `app/controllers/application_controller.rb`
   - Changes: Inherit from `ActionController::API` instead of `ActionController::Base`
   - Remove `allow_browser` constraint

2. **`ApplicationRecord < ActiveRecord::Base`**
   - File: `app/models/application_record.rb`
   - Changes: None needed, keep `primary_abstract_class`

3. **`TestCase < ActiveSupport::TestCase`**
   - File: `test/test_helper.rb`
   - Changes: Add authentication helper methods for testing API endpoints
   - Add `include AuthHelpers` module

### Removed Classes

`Employee < ApplicationRecord` and the `employees` table were removed after
their profile fields and relationships were migrated to `users`.

## Dependencies

### New Gems to Add (Rails Backend)

1. **`gem 'devise'`** - Authentication framework
2. **`gem 'rack-cors'`** - CORS middleware for React frontend API calls
3. **`gem 'jsonapi-serializer'`** - JSON:API compliant response serialization (or use `active_model_serializers`)
4. **`gem 'jbuilder'`** - Already in Gemfile, for building JSON responses

### React Frontend Dependencies (in frontend/package.json)

1. **`axios`** - HTTP client for API calls
2. **`react`** and **`react-dom`** - Core React library
3. **`react-router-dom`** - Client-side routing
4. **`formik`** and **`yup`** - Form handling and validation
5. **`@tanstack/react-query`** or **`react-query`** - Server state management
6. **`react-icons`** - Icon components
7. **`date-fns`** - Date utilities

### Gems Already Available
- Rails 8.1.4
- PostgreSQL adapter (pg)
- turbo-rails, stimulus-rails (may remove if purely API mode)
- puma (web server)
- jbuilder, propshaft (asset pipeline)

## Testing

### Test File Requirements

1. **`test/models/user_test.rb`**
    - Test user creation and authentication
   - Test Devise session creation

2. Employee profile validations, associations, scopes, and behavior are tested
   through `test/models/user_test.rb` and `test/models/salary_test.rb`.

4. **`test/models/salary_test.rb`**
   - Test validations (amount, currency, salary_type, effective_date)
   - Test enum values (base, bonus, commission, equity)
   - Test scopes (current, by_employee, by_type)
   - Test `is_current` behavior when creating new salaries

5. **`test/models/department_test.rb`**
   - Test validations (name presence, uniqueness)
   - Test associations (employees, manager)
   - Test methods (headcount, total_salary_budget)

6. **`test/models/location_test.rb`**
   - Test validations (country, city, timezone)
   - Test methods (display_name, headcount)

7. **`test/controllers/api/v1/employees_controller_test.rb`**
   - Test API endpoints (index, show, create, update, delete)
   - Test pagination and filtering
   - Test authentication requirements

8. **`test/controllers/api/v1/salaries_controller_test.rb`**
   - Test CRUD operations
   - Test current salary retrieval
   - Test nested routes

9. **`test/controllers/api/v1/reports_controller_test.rb`**
   - Test report generation (department salaries, job title averages)
   - Test CSV export

10. **`test/controllers/api/auth_controller_test.rb`**
    - Test login with valid credentials
    - Test login failure with invalid credentials
    - Test logout/revocation

11. **`test/fixtures/`**
    - `employees.yml` - Sample employee data
    - `salaries.yml` - Sample salary data
    - `departments.yml` - Sample departments
    - `locations.yml` - Sample locations
    - `users.yml` - Sample users (including admin HR manager)

### Existing Test Modifications

1. Modify `test/test_helper.rb` to:
   - Add helper methods for authentication in tests
   - Configure test database
   - Add FactoryBot or use fixtures

### Validation Strategies

1. **Model-level validations** - Test presence, uniqueness, format
2. **API response validation** - Test correct JSON structure and status codes
3. **Authentication validation** - Test that protected endpoints return 401 without token
4. **Edge cases** - Test soft delete behavior, salary history, currency handling

## Implementation Order

1. **Setup Phase**
    - Update Gemfile with devise, rack-cors, jsonapi-serializer
   - Run `bundle install`
   - Configure Devise in `config/initializers/devise.rb`
   - Configure CORS in `config/initializers/cors.rb`
   - Update `config/application.rb` for API mode
   - Update `app/controllers/application_controller.rb` to inherit from `ActionController::API`
   - Configure `config/database.yml` with proper PostgreSQL settings

2. **Database Setup**
    - Generate and run Devise user migration (`rails generate devise:install`)\n   - Create migrations for Employee, Salary, Department, Location tables
   - Run `rails db:create` and `rails db:migrate`

3. **Model Implementation**
    - Create `app/models/user.rb` with Devise configuration
   - Create `app/models/department.rb` with validations and associations
   - Create `app/models/location.rb` with validations and associations
   - Create `app/models/employee.rb` with validations, associations, scopes, and methods
   - Create `app/models/salary.rb` with validations, enum, scopes, and methods

4. **API Controllers**
   - Create `app/controllers/api/base_controller.rb` with authentication before_action
   - Create `app/controllers/api/auth_controller.rb` for login/logout
   - Create `app/controllers/api/v1/employees_controller.rb`
   - Create `app/controllers/api/v1/salaries_controller.rb`
   - Create `app/controllers/api/v1/departments_controller.rb`
   - Create `app/controllers/api/v1/locations_controller.rb`
   - Create `app/controllers/api/v1/reports_controller.rb`

5. **Routing**
   - Update `config/routes.rb` with API namespace and all routes
   - Add authentication routes (login, logout, register)

6. **Seed Data**
   - Update `db/seeds.rb` to create:
    - Departments (10-15)
    - Locations (15-20 countries/cities)
    - 10,000 Employees with randomized data
    - Current salary for each employee

7. **React Frontend Setup**
   - Create `frontend/` directory with package.json
   - Set up React with Vite or Create React App
   - Configure axios instance with Devise session config
   - Create services for each API resource
   - Create custom hooks for data fetching
   - Build UI components for:
    - Login page
    - Employee list/detail/form pages
    - Salary list/form components
    - Department management
    - Location management
    - Reports dashboard

8. **Integration**
   - Configure Rails to serve React build files in production
   - Update Dockerfile to build React app
   - Update Procfile.dev for concurrent Rails + React dev servers

9. **Testing**
   - Update `test/test_helper.rb` with authentication helpers
   - Create model tests for all entities
   - Create controller tests for all API endpoints
   - Create fixture files for test data
   - Run tests and ensure 80%+ coverage on core logic

10. **Documentation**
    - Document API endpoints with examples
    - Create deployment instructions
    - Add README updates for running the application