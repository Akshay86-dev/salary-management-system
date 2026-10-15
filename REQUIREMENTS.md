# Salary Management Requirements

## Product scope

The application supports HR workflows for employee profiles, compensation
history, departments, locations, and reporting. It includes role-based
authentication, salary change versioning, and CSV exports. It does not process
payroll or payments.

## Implemented functionality

- Manage active and archived employee profiles, with search and filters.
- Associate employees with a department, location, and salary history.
- Record salaries by type, effective date, and ISO-style three-letter currency.
- Manage departments and locations.
- Report salary totals and averages by department, job title, and currency.
- Compare department compensation by currency.
- Export employee and salary data as CSV.
- Seed configurable development datasets; see [docs/seeding.md](./docs/seeding.md).
- Serve a React single-page application and Rails JSON API from one production
  origin.

## Architecture

- Backend: Ruby on Rails 8.1
- Database: PostgreSQL
- Authentication: Devise with JWT bearer authentication; HR roles are required
  for protected API operations.
- Change history: PaperTrail versions for tracked model changes.
- Frontend: React 18, TypeScript, Vite, and React Router.
- Deployment: Docker production image; the image builds the React frontend and
  serves it alongside Rails.

## Verification expectations

- Model and API tests cover authentication, employee and salary CRUD, reports,
  and seed behavior.
- Frontend build, lint, and TypeScript checks run independently.
- Performance at 10,000 employee records and complete browser workflows require
  explicit end-to-end or benchmark verification.
