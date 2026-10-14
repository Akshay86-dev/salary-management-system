# Salary Management System - Requirements Document

## Goal

Build employee salary management software for an organization with 10,000 employees across multiple countries. The system will replace error-prone Excel-based salary management with a centralized web application that allows HR managers to manage employee salary data and answer questions about compensation across the organization.

## Scope & Features

### Core Features

1. **Employee Management**
   - View list of all employees with pagination and search by name, email, or employee ID
   - View individual employee details (personal info, job title, department, location)
   - Create new employees with associated salary information
   - Edit existing employee records and salary details
   - Delete/archive employees (soft delete for audit trail)

2. **Salary Management**
   - View current salary details for each employee
   - Record salary history with effective dates (track raises, promotions, adjustments)
   - Support currency handling for international employees (USD, EUR, GBP, etc.)
   - Calculate and display annual compensation including bonuses and variable pay

3. **Reporting & Analytics**
   - View salary totals by department
   - View average salary by job title
   - Salary comparison across departments
   - Export reports in CSV format
   - Filter and sort capabilities

4. **Department & Location Management**
   - Manage departments (create, update, delete, assign employees)
   - Track employee work locations/countries
   - View headcount and salary budgets by department/location

### Technical Architecture

- Backend: Ruby on Rails 8.x (monolithic, API + server-rendered views)
- Frontend: React.js integrated with Rails via API endpoints
- Database: PostgreSQL for data persistence
- Authentication: Device-based authentication using Devise (session/cookie-based)
- Audit Trail: Automatic logging of all data changes
- Deployment: Docker containerized, deployable to any cloud provider

### User Personas

1. HR Manager (Primary User)
   - Manages all employee and salary data
   - Creates, reads, updates, and deletes employee records
   - Generates reports and views analytics
   - Seeds and imports bulk employee data

## Authentication

1. Device-based authentication using Devise (session/cookie-based).
2. Single user type: HR Manager.
3. Authentication is required for all API endpoints.
4. Users authenticate via login endpoint using Devise sessions.
5. Session cookie is used for subsequent API requests.

## Audit Trail

1. Automatic audit logging for all employee and salary changes.
2. Tracks create, update, and delete operations.
3. Records user who made the change, timestamp, and before/after data.
4. Read-only audit trail for compliance and troubleshooting.

## Out of Scope (Deliberately Excluded)

The following are intentionally left out of this assessment to maintain focus on core engineering quality:

1. Payroll Processing - No actual payment processing, tax calculations, or integration with banking systems.
   Reasoning: This would require third-party integrations and financial compliance knowledge.

2. Real-time Collaboration - No concurrent editing, notifications, or live updates.
   Reasoning: Adds complexity (WebSockets, conflict resolution) beyond the scope of this exercise.

3. Mobile App - No native mobile application; responsive web UI only.
   Reasoning: Mobile development would double the frontend effort; responsive design suffices for HR desktop workflows.

4. Multi-language UI - English-only interface, though data supports international currencies.
   Reasoning: Localization adds complexity without core value for this assessment.

5. Email Notifications - No email alerts for changes or reports.
   Reasoning: Adds complexity around email infrastructure without core value.

## Data Model Overview

- Employee: name, email, employee_id, job_title, department, location, hire_date
- Salary: employee_id, amount, currency, effective_date, salary_type (base/bonus/commission)
- Department: name, budget, manager
- Location: country, city, timezone

## Seeding Requirements

- Script to generate 10,000 employees with realistic data
- Distribution across 10-15 departments
- Employees in multiple countries (US, UK, Germany, India, Brazil, etc.)
- Varied salary ranges based on role and location

## Testing Requirements

- Unit tests for models and business logic
- Controller/integration tests for API endpoints
- Test suite that is fast and deterministic
- Coverage for core CRUD operations and reporting queries

## Success Criteria

- Application is fully functional and deployed
- 10,000 employees can be seeded and queried efficiently
- HR manager can perform all CRUD operations on employees and salaries
- Reports generate accurate results
- All tests pass
- Code is clean, well-structured, and documented