# Salary Management System - Requirements Document

## Goal
Build a web-based salary management system that enables HR managers to manage salary data for 10,000 employees across multiple countries, replacing tedious Excel-based processes with an intuitive, efficient web application.

## Scope & Features

### In Scope:
- **Employee Management**: Store and manage employee records including personal details, job titles, departments, and locations
- **Salary Management**: Record, view, edit, and query salary information for all employees
- **Search & Filtering**: Find employees by name, department, location, or job title
- **Salary Analytics**: View aggregate statistics such as average salary by department, location, or job title
- **Data Import/Export**: Seed 10,000 employees with realistic data; export salary reports
- **Responsive UI**: Modern React-based interface optimized for HR workflows

### Out of Scope (Deliberately Excluded):
- **User Authentication**: No login system (focus on core domain logic)
- **Payroll Processing**: No integration with actual payment systems
- **Audit Logs**: No historical tracking of salary changes (can be a future enhancement)
- **Multi-language Support**: English-only interface (can be added later)
- **Advanced Reporting**: No custom report builder or scheduling (basic analytics only)
- **Mobile App**: Web-only solution (responsive design handles mobile browsers)

### Reasoning for Exclusions:
The assessment focuses on demonstrating clean software architecture and engineering fundamentals. By limiting scope to core salary management, we ensure a well-structured, maintainable solution that can be extended later. Authentication, audit logs, and advanced reporting are important but would add complexity that distracts from the primary goal.

## User Persona
**HR Manager**: Responsible for managing compensation data for 10,000 employees spread across multiple countries. Needs quick access to employee salary information, ability to update records, and generate reports on compensation trends within the organization.

## Technical Requirements
- **Backend**: Ruby on Rails (API + minimal server-side rendering)
- **Database**: SQLite (per assessment constraints; can scale to PostgreSQL later)
- **Frontend**: ReactJS with a modern component library (Mantine or Material UI)
- **Seeding**: Script to generate 10,000 employees with realistic salary data across departments and countries
- **Deployment**: Docker containerization for easy deployment
- **Testing**: Unit tests covering core business logic and API endpoints

## Success Criteria
- Application handles 10,000 employee records efficiently
- HR manager can perform CRUD operations on employee salaries
- Search and filtering return results in under 1 second
- Basic analytics provide meaningful insights
- Codebase is clean, well-tested, and maintainable