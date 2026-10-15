# Salary Management System - Design Document

## Models & Relationships

### 1. User (account and employee profile)

```ruby
class User < ApplicationRecord
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable,
         :timeoutable, :trackable
  enum :role, { employee: "EMPLOYEE", human_resource: "HUMAN_RESOURCE" },
       default: :employee

  validates :first_name, :last_name, :email, presence: true
end
```

**Fields:**
- `first_name: string`
- `last_name: string`
- `email: string` (unique, used for login)
- `encrypted_password: string`
- `role: string` (`EMPLOYEE` or `HUMAN_RESOURCE`; defaults to `EMPLOYEE`)
- `employee_id`, `job_title`, `hire_date`, `department_id`, `location_id`,
  and `is_active` for employee profiles
- `created_at`, `updated_at` timestamps

**Relationships:**
- `belongs_to :department` and `belongs_to :location` for employee profiles
- `has_many :salaries` for employee profiles
- `has_many :versions` (PaperTrail records associated with this user)

HR users may omit employee profile fields. Employee-profile data is identified
by a non-null `employee_id`; only HR-role users may authenticate or access
protected API endpoints. See [roles_and_authentication.md](roles_and_authentication.md)
for migration and security details.

### 2. Audit

```ruby
class Audit < ApplicationRecord
  belongs_to :user, optional: true
  enum action: { create: 0, update: 1, delete: 2 }
  enum auditable_type: { employee: 0, salary: 1, department: 2, location: 3 }

  validates :action, :auditable_type, :auditable_id, presence: true

  # Store before/after state as JSON
  serialize :previous_data, coder: JSON
  serialize :new_data, coder: JSON
end
```

**Fields:**
- `user_id: integer` (foreign key to User, nullable for system actions)
- `action: integer` (enum: create, update, delete)
- `auditable_type: integer` (enum: employee, salary, department, location)
- `auditable_id: integer` (the ID of the affected record)
- `previous_data: jsonb` (state before change, null for creates)
- `new_data: jsonb` (state after change, null for deletes)
- `ip_address: string` (IP of the requesting client)
- `user_agent: string` (browser/device info)
- `created_at` timestamp

**Relationships:**
- `belongs_to :user` (optional, for system actions like seeding)

### 3. Employee profile (stored on User)

```ruby
class User < ApplicationRecord
  belongs_to :department, optional: true
  belongs_to :location, optional: true
  has_many :salaries, foreign_key: :employee_id
end
```

The former employee columns live in the `users` table. The existing employees
API remains available, but operates on `User` records with employee profiles.

### 4. Salary

```ruby
class Salary < ApplicationRecord
  belongs_to :employee, class_name: 'User', foreign_key: :employee_id
  enum salary_type: { base: 0, bonus: 1, commission: 2, equity: 3 }

  validates :amount, :currency, :effective_date, :salary_type, presence: true
  validates :is_current, inclusion: { in: [true, false] }

  scope :current, -> { where(is_current: true) }
  scope :by_employee, ->(id) { where(employee_id: id) }
end
```

**Fields:**
- `employee_id: integer` (foreign key)
- `amount: decimal` (the salary amount)
- `currency: string` (ISO 4217 code like "USD", "EUR", "GBP")
- `salary_type: integer` (enum: base, bonus, commission, equity)
- `effective_date: date`
- `is_current: boolean` (default: true; setting a new one sets previous to false)
- `created_at`, `updated_at` timestamps

**Relationships:**
- `belongs_to :employee`

### 5. Department

```ruby
class Department < ApplicationRecord
  has_many :employees, class_name: 'User', dependent: :nullify
  belongs_to :manager, class_name: 'User', optional: true

  validates :name, presence: true, uniqueness: true
end
```

**Fields:**
- `name: string`
- `budget: decimal`
- `manager_id: integer` (optional, references User)
- `created_at`, `updated_at` timestamps

**Relationships:**
- `has_many :employees`
- `belongs_to :manager` (self-referencing Employee, optional)

## Database Relationships Diagram

```
User
  - has_many :audits

Audit
  - user_id -> User (optional)
  - auditable_type (employee, salary, department, location)
  - auditable_id

Salary
  - employee_id -> User

Department
  - manager_id -> User
  - has_many :employees

Location
  - has_many employee-profile users
```

## Authentication Endpoints

| Method   | Endpoint                    | Description                          |
|----------|-----------------------------|--------------------------------------|
| POST     | `/api/auth/login`           | Authenticate user via Devise session |
| DELETE   | `/api/auth/logout`          | Delete session and sign out          |
| POST     | `/api/users/register`       | Register new HR manager (setup only) |

## API Endpoints (JSON:API compliant)

All endpoints below require authentication via Devise session.

### Authentication Routes

| Method   | Endpoint                    | Controller Action    |
|----------|-----------------------------|----------------------|
| POST     | `/api/auth/login`           | AuthController#create |
| DELETE   | `/api/auth/logout`          | AuthController#destroy |
| POST     | `/api/users/register`       | UsersController#create |

### Employees

| Method   | Endpoint                    | Description                          |
|----------|-----------------------------|--------------------------------------|
| GET      | `/api/employees`            | List all employees (paginated)       |
| GET      | `/api/employees/:id`        | Get specific employee                |
| POST     | `/api/employees`            | Create new employee                  |
| PATCH    | `/api/employees/:id`        | Update employee                      |
| DELETE   | `/api/employees/:id`        | Soft-delete employee                 |

**Query Parameters for Listing:**
- `page[number]` and `page[size]` for pagination
- `filter[name]` or `filter[query]` for search
- `filter[department_id]` to filter by department
- `sort=last_name,first_name` for ordering

### Salaries

| Method   | Endpoint                      | Description                          |
|----------|-------------------------------|--------------------------------------|
| GET      | `/api/salaries`               | List all salaries                    |
| GET      | `/api/salaries/:id`           | Get specific salary                  |
| POST     | `/api/salaries`               | Create new salary                    |
| PATCH    | `/api/salaries/:id`           | Update salary                        |
| DELETE   | `/api/salaries/:id`           | Delete salary                        |

**Nested Routes:**
- GET `/api/employees/:employee_id/salaries` - List salaries for an employee
- POST `/api/employees/:employee_id/salaries` - Create salary for an employee

### Departments

| Method   | Endpoint                    | Description                          |
|----------|----------------------------|--------------------------------------|
| GET      | `/api/departments`         | List all departments                 |
| GET      | `/api/departments/:id`     | Get specific department              |
| POST     | `/api/departments`         | Create new department                |
| PATCH    | `/api/departments/:id`     | Update department                    |
| DELETE   | `/api/departments/:id`     | Delete department                    |

### Locations

| Method   | Endpoint                   | Description                          |
|----------|---------------------------|--------------------------------------|
| GET      | `/api/locations`          | List all locations                   |
| GET      | `/api/locations/:id`      | Get specific location                |
| POST     | `/api/locations`          | Create new location                  |
| PATCH    | `/api/locations/:id`      | Update location                      |
| DELETE   | `/api/locations/:id`      | Delete location                      |

### Reports (Read-only endpoints)

| Method   | Endpoint                              | Description                              |
|----------|---------------------------------------|------------------------------------------|
| GET      | `/api/reports/department_salaries`    | Salary totals by department              |
| GET      | `/api/reports/job_title_averages`     | Average salary by job title              |
| GET      | `/api/reports/headcount_by_location`  | Employee count by location               |
| GET      | `/api/reports/employee_count_by_currency` | Employees grouped by currency      |
| GET      | `/api/reports/export`                 | Export employee data as CSV              |
| GET      | `/api/reports/audit_trail`            | View audit log entries                   |

**Report Query Parameters:**
- `filter[department_id]` - Filter by department
- `filter[currency]` - Filter by currency
- `filter[date_from]` and `filter[date_to]` - Date range for salary effective dates

**Audit Trail Query Parameters:**
- `filter[auditable_type]` - Filter by model type (employee, salary, etc.)
- `filter[action]` - Filter by action type (create, update, delete)
- `filter[user_id]` - Filter by user who made the change

## React Frontend Structure

```
frontend/
  public/
  src/
    components/
      employees/
        EmployeeList.jsx
        EmployeeDetail.jsx
        EmployeeForm.jsx
      salaries/
        SalaryList.jsx
        SalaryForm.jsx
      departments/
        DepartmentList.jsx
        DepartmentForm.jsx
      locations/
        LocationList.jsx
        LocationForm.jsx
      reports/
        DepartmentSalariesReport.jsx
        JobTitleAveragesReport.jsx
        HeadcountByLocationReport.jsx
      shared/
        Pagination.jsx
        SearchFilter.jsx
        ConfirmDialog.jsx
        hooks/
      useApi.js
      useEmployees.js
      useSalaries.js
      useDepartments.js
      useLocations.js
      useReports.js
      useAuth.js
    services/
             api.js (axios instance with session/cookie config)
      authService.js
      employeeService.js
      salaryService.js
      departmentService.js
      locationService.js
      reportService.js
    App.jsx
    index.js
```

### API Response Format (JSON:API Spec)

```json
{
  "data": {
    "id": "1",
    "type": "employee",
    "attributes": {
      "first_name": "John",
      "last_name": "Doe",
      "email": "john.doe@acme.com",
      "employee_id": "EMP-00001",
      "job_title": "Software Engineer",
      "hire_date": "2023-01-15",
      "is_active": true
    },
    "relationships": {
      "department": {
        "data": { "id": "1", "type": "department" }
      },
      "location": {
        "data": { "id": "1", "type": "location" }
      },
      "current_salary": {
        "data": { "id": "1", "type": "salary" }
      }
    }
  }
}
```

### Error Response Format

```json
{
  "errors": [
    {
      "source": { "pointer": "/data/attributes/email" },
      "detail": "has already been taken"
    }
  ]
}
```

## Model Behaviors & Business Logic

### Salary Management Logic
- When creating a new salary for an employee:
  - Set `is_current: true` on the new salary
  - Set `is_current: false` on any previous current salary for that employee
  - Ensure `effective_date` is unique per employee for current salaries

### Employee Soft Delete
- Instead of hard delete, set `is_active: false`
- Add scope `active` for querying active employees
- Salaries remain intact for historical reporting

### Search & Filter Logic
- Employee search filters across: first_name, last_name, email, employee_id, job_title
- Case-insensitive search with partial matching
- Date range filtering for hire_date and salary effective_date

### Report Calculations
- **Department Salary Totals**: Sum of all current base salaries by department
- **Job Title Averages**: Average of current base salaries grouped by job_title
- **Headcount by Location**: Count of active employees by location
- All amounts converted to a common currency (USD) using exchange rates for comparison (assumed rate data is available)

### Audit Logging Behavior
- Automatically create audit records on create/update/delete for Employee, Salary, Department, and Location
- Capture before and after states of changed attributes
- Record the authenticated user who made the change
- Log IP address and user agent for security tracking
- Audit records are immutable (no delete/edit capability)

## Validations Summary

### Employee
- first_name, last_name, email, employee_id, job_title, hire_date: required
- email: unique, valid format
- employee_id: unique
- department_id, location_id: must reference valid records

### Salary
- amount: required, must be positive number
- currency: required, must be valid ISO 4217 code
- effective_date: required
- salary_type: required (enum)
- is_current: boolean

### Department
- name: required, unique
- budget: optional
- manager_id: optional

### Location
- country: required
- city: required
- timezone: required

### User
- first_name, last_name, email: required
- email: unique
- password: required (minimum 6 characters via Devise)

### Audit
- action, auditable_type, auditable_id: required
- user_id: optional (for system actions)
- previous_data, new_data: optional (JSON storage)