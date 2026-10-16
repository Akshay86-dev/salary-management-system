# Salary Management System

A full-stack HR application for managing employee profiles, departments,
office locations, salary history, and compensation reports. It uses a Ruby on
Rails JSON API, a React single-page frontend, and PostgreSQL.

## Project overview

The application provides HR-user authentication with Devise and JWT, employee
profile management, department and location management, salary history,
compensation reports, CSV exports, dashboard summaries, and model change
history. Employees are managed as profiles rather than interactive accounts.
The React frontend uses client-side routing and a persistent light/dark theme.

| Area | Technology |
| --- | --- |
| Backend/API | Ruby 3.3, Rails 8.1.4 |
| Database | PostgreSQL |
| Frontend | React 18, TypeScript, React Router 6 |
| Frontend tooling | Node.js 22, npm, Vite 5 |
| Authentication | Devise, Devise JWT |
| History and serialization | PaperTrail, jsonapi-serializer |
| Testing and quality | Rails/Minitest, RSpec, Capybara, Selenium, RuboCop, Brakeman, ESLint, TypeScript |

## Seed data at a glance

| Profile | Command | Employees |
| --- | --- | ---: |
| Small | `bin/rails db:seed:small` | 100 |
| Default | `bin/rails db:seed` | 10,000 |
| Large | `bin/rails db:seed:large` | 50,000 |

Each profile also seeds or reuses 12 departments and 18 office locations,
ensures an HR administrator exists, generates salary history for the seeded
employees, and assigns department managers. Employee and salary records are
randomly generated; repeating a profile does not reproduce the same dataset.

The default 10,000-record profile is useful for realistic local development
and exercising list, search, dashboard, and report features. Use `small` for
quick setup and tests that need seed-like data, or `large` to explore behavior
with more records. Seed commands run synchronously and print step progress and
final database counts.

## Before seeding

1. Install the dependencies described in [Prerequisites](#prerequisites).
2. Configure PostgreSQL and the environment as described in
   [Setup](#setup).
3. Confirm your shell points to the intended development database. The default
   is `salary_management_development`; `DATABASE_URL` can override the
   connection settings.
4. Prepare the database and apply migrations:

   ```sh
   bin/rails db:prepare
   ```

5. Run one profile:

   ```sh
   bin/rails db:seed:small
   # or: bin/rails db:seed
   # or: bin/rails db:seed:large
   ```

To see the seed-related rake tasks available in the current checkout, run
`bin/rails -T db:seed`.

### What a seed run changes

- **Departments:** Creates missing departments from the configured list using
  `find_or_create_by!`; existing departments and budgets are reused unchanged.
- **Locations:** Creates missing locations using their configured name, city,
  state, and country, with Faker-generated street address, ZIP code, latitude,
  and longitude. Existing locations are reused unchanged.
- **HR account:** Creates `admin@salarymgmt.com` with the name `Admin User` and
  the `human_resource` role only if no HR users exist. If any HR user already
  exists, it is left unchanged and no new admin is created.
- **Employees:** Deletes existing employee profiles and their salaries, then
  inserts the chosen number of new profiles in batches of 1,000. Employee
  attributes include a generated name and email, an `EMP-00001`-style ID,
  department, location, job title, hire date from the last five years, and an
  active/inactive status. IDs are checked against existing employee IDs.
- **Salaries:** Creates a base salary for each employee and, at random, may add
  bonus, commission, and equity records. Base salary amounts are in the
  configured range of 45,000–250,000; currencies include USD, CAD, and EUR.
  Salary inserts are batched at 1,000 records.
- **Department managers:** Assigns a randomly selected active employee from
  each department when one is available.

The run order is intentional: departments and locations are created before
employees reference them, salaries follow employee creation, and managers are
assigned last. Employee and salary records are inserted in batches with
Active Record bulk-insert APIs. The run is **not wrapped in one transaction**;
if a step fails, the database may contain partially regenerated data.

### Seed administrator password

In development and test, if no HR user exists, the generated administrator
password is `password123` unless `SEED_ADMIN_PASSWORD` is set. For local use,
set a password before seeding if you do not want the default:

```sh
SEED_ADMIN_PASSWORD='use-a-local-development-password' bin/rails db:seed:small
```

Do not use the default password for an exposed environment. In production, the
runner rejects all profiles before executing any seed steps. The administrator
step also requires `SEED_ADMIN_PASSWORD` if reached in production; this is a
separate safeguard, not an enablement of production profile seeding. Never
commit credentials or real passwords.

## Seeding implementation

The public entry point for the default seed is [db/seeds.rb](db/seeds.rb),
which calls `Seeding::SeedRunner.call(profile: :default)`. Named profile tasks
are registered in [lib/tasks/seeding.rake](lib/tasks/seeding.rake) from the
profiles in [lib/seeding/configuration.rb](lib/seeding/configuration.rb).
`SeedRunner` validates the profile, blocks production use, then coordinates
the six steps in dependency order:

1. `DepartmentSteps#seed_departments`
2. `LocationSteps#seed_locations`
3. `AdminUserSteps#seed_admin_user`
4. `EmployeeSteps#seed_employees`
5. `SalarySteps#seed_salaries`
6. `DepartmentManagerSteps#assign_department_managers`

The step modules live in `lib/seeding/`. `EmployeeGenerator` and
`SalaryGenerator` keep generated attributes separate from the code that
persists them. The shared configuration defines profile counts, batch sizes,
the salary range, departments, locations, job titles, and currency choices.
The code-level entry point can also be used from a Rails console, for example:

```ruby
Seeding::SeedRunner.call(profile: :small)
```

Treat that call with the same data-loss precautions as the rake task. Profiles
accept `:small`, `:default`, or `:large`; other values raise an error.

For more details on organization and safety behavior, see
[docs/seeding.md](docs/seeding.md).


## Prerequisites

- Ruby **3.3** and Bundler.
- Node.js **22** and npm for frontend development or builds.
- PostgreSQL, running locally or reachable via `DATABASE_URL`.
- A C/C++ toolchain and PostgreSQL development headers if native gems need to
  be compiled.
- Chrome or Chromium for browser-based system tests.

## Setup

Install the Ruby and frontend dependencies from the repository root:

```sh
bundle install
npm ci --prefix frontend
```

The app uses PostgreSQL. By default, Rails connects to
`salary_management_development`; the test database is
`salary_management_test`. Database connection settings can be provided by
standard PostgreSQL environment variables or `DATABASE_URL`.

Create the development database and apply migrations:

```sh
bin/rails db:prepare
```

### Environment configuration

Optionally copy the sample environment file:

```sh
cp .env.example .env
```

Rails and Vite do not load `.env` automatically. In each terminal where you
need those settings, load the file from the repository root:

```sh
set -a
. ./.env
set +a
```

Relevant settings include:

| Variable | Purpose |
| --- | --- |
| `DATABASE_URL` | Optional PostgreSQL connection URL; Rails merges it with `config/database.yml`. |
| `RAILS_MAX_THREADS` | Database connection pool size; defaults to 5 in `config/database.yml`. |
| `SEED_ADMIN_PASSWORD` | Password used when creating the seeded HR admin. Development/test default is `password123`; set a secure value where required. |
| `PORT` | Rails/Puma HTTP port; defaults to 3000. |
| `SALARY_MANAGEMENT_DATABASE_PASSWORD` | Production DB password when not using `DATABASE_URL`. |
| `RAILS_MASTER_KEY` | Production Rails credentials key. Keep it secret. |
| `DEVISE_JWT_SECRET` | Optional dedicated JWT signing secret. |
| `CORS_ORIGINS` | Comma-separated frontend origins allowed by production CORS. |
| `RAILS_LOG_LEVEL`, `JOB_CONCURRENCY` | Production logging level and Solid Queue worker count. |

Use secure secrets from a deployment secret manager in production. Never
commit `.env`, credentials, or generated secrets.

## Usage

Start the Rails API from the repository root:

```sh
bin/rails server
```

In another terminal, start the frontend:

```sh
cd frontend
npm run dev
```

Open <http://localhost:5173>. Vite proxies API, user, and health-check requests
to Rails at <http://localhost:3000>. To build the frontend for a
single-origin Rails deployment:

```sh
npm run build --prefix frontend
RAILS_ENV=production bin/rails server
```

Production also requires a configured Rails master key, PostgreSQL, and
deployment-specific settings. The Docker image builds the frontend and serves
it through Rails.

The JSON API is rooted at `/api/v1`; most operations require an HR user's JWT.
For the live endpoint list, run:

```sh
bin/rails routes
```

The seed-generated HR account can be used to sign into the local application
when it was newly created and its password is known. Seeded employee records
are profile data, not employee login accounts.

## Tests and quality checks

```sh
bin/rails test
bundle exec rspec
```

System tests require Chrome/Chromium and a built frontend:

```sh
npm run build --prefix frontend
bin/rails test:system
```

Other available checks:

```sh
bin/rubocop -f simple
bin/brakeman --no-pager
bin/bundler-audit
npm run lint --prefix frontend
npm run type-check --prefix frontend
```

## Repository layout

```text
app/models/       Users, departments, locations, and salaries
config/           Rails and database configuration
db/seeds.rb       Default seed entry point
frontend/         React, TypeScript, and Vite application
lib/seeding/      Seed profiles, configuration, generators, and steps
lib/tasks/        Seed profile rake tasks
docs/             Project and seeding documentation
test/             Rails/Minitest tests
spec/             RSpec tests
```
