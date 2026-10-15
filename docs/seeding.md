# Seed command organization

`db/seeds.rb` is intentionally small. It invokes `Seeding::SeedRunner.call`, the
single workflow coordinator. `SeedRunner` extends focused step modules so their
instance methods are available at the class level, preserving the
`SeedRunner.call` entry point. The runner executes the steps in dependency
order:

1. `DepartmentSteps#seed_departments`
2. `LocationSteps#seed_locations`
3. `AdminUserSteps#seed_admin_user`
4. `EmployeeSteps#seed_employees`
5. `SalarySteps#seed_salaries`
6. `DepartmentManagerSteps#assign_department_managers`

The step modules live in `lib/seeding/`. The employee and salary steps handle
batch persistence; `EmployeeGenerator` and `SalaryGenerator` produce the
domain-specific attributes. This keeps random-data rules separate from
database writes. Employee generation receives seeded departments and
locations; salary generation runs after employee profiles exist; manager
assignment runs last. The runner uses `extend`, not `include`, because these
are class-level methods and the public API remains `SeedRunner.call`.

Shared settings and profile sizes live in `configuration.rb`. The default
profile creates 10,000 employees; `small` creates 100 and `large` creates
50,000. All profiles create fresh random employee and salary data on each run.

Run the default profile with:

```sh
bin/rails db:seed
```

Run a named profile with:

```sh
bin/rails db:seed:small
bin/rails db:seed:large
```

Profile runs are blocked in production because they delete and recreate
employee and salary records. They currently do not wrap the full run in a
transaction, so a failed run may leave partially regenerated data.

In development and test the HR admin seed password defaults to `password123`.
Department and location records are find-or-created. Existing HR admin users
are left unchanged.
