# User and employee data

Employee personnel fields now live on `users`; there is no separate
`employees` table or `Employee` model. The `users` table stores Devise
credentials and role information alongside optional employee-profile fields:
employee ID, job title, hire date, department, location, and active status.

The role is a string enum, `EMPLOYEE` or `HUMAN_RESOURCE`, defaulting to
`EMPLOYEE`. A database check constraint restricts role values and requires
employee profile fields for `EMPLOYEE` role records. HR users may exist without
an employee profile. If an HR account matches an existing employee by email,
that user remains `HUMAN_RESOURCE` and receives the employee's profile fields.
An employee profile is identified by a non-null `employee_id`, independently
of the role.

## Authentication and authorization

Only `HUMAN_RESOURCE` users can authenticate. Employee-profile users have an
empty password hash when imported and password validation is not required for
employee-role records. Devise's authentication check rejects employee roles,
and protected API requests additionally check the current user's role in the
database. Public registrations remain disabled. Employee profile management
uses the existing `/api/v1/employees` API for compatibility; those endpoints
now read and write `User` rows.

## Data migration

The migration preserves records and relationships as follows:

1. It checks that emails are nonblank and unique after trimming and
   case-normalization in each table. It stops with a migration error if it finds
   ambiguity or an existing `EMPLOYEE` user without a matching employee row;
   resolve the records before retrying.
2. Existing users are normalized to lowercase email. An employee whose email
   matches an existing user updates that user's profile fields and retains the
   existing user's role and credentials.
3. An employee without a matching user becomes a new `EMPLOYEE` user with an
   empty encrypted password. Such a user cannot authenticate.
4. Salary employee IDs, department manager IDs, and PaperTrail `Employee`
   references are remapped to the corresponding user IDs.
5. Foreign keys are pointed at `users`, employee-profile indexes and constraints
   are added, and the old `employees` table is dropped.

Take a database backup and schedule a maintenance window before migration.
Stop web workers and background jobs before the schema migration, then deploy
the new code and restart them after it succeeds; the old and new application
versions cannot safely run concurrently while `employees` is dropped. The
mapping is by normalized email;
review matches beforehand, particularly if a user's email and employee record
do not identify the same person. The migration is intentionally irreversible
because merged records cannot be reliably split back into their original
tables. Rollback requires restoring the pre-migration backup.

Before restoring service, verify that at least one authorized HR account exists.
If not, provision one through a trusted process or run the seed task with a
`SEED_ADMIN_PASSWORD`; in development and test, it defaults to `password123`.
Production seeding requires `SEED_ADMIN_PASSWORD` to be explicitly set. The
seed creates an HR admin when there is no HR account, even if employee users
already exist. Do not use the development default in production.

## Security

- Devise stores bcrypt password hashes, never plaintext passwords. Employee
  records imported by the migration have no usable password and cannot log in
  due to the HR-only authentication guard.
- Do not accept `role` through employee API parameters. Provision HR accounts
  through a trusted process and grant the HR role explicitly.
- Password and reset-token fields are excluded from PaperTrail versioning.
- Use TLS and deployment secrets for JWT signing keys; never log credentials,
  reset tokens, or JWT values.
- The API checks authorization independently of the client-provided role, so a
  role change takes effect on subsequent requests.
