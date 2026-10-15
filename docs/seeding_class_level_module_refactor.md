# Seeding class-level module refactor

This document records the class-level module refactor. `Seeding::SeedRunner.call`
uses seeding steps provided by modules while preserving the Rake task interface
and the order of operations.

## `include` versus `extend`

`include SomeModule` adds the module's instance methods to a class's instances.
That would require changing the runner to an instance-based API, such as
`Seeding::SeedRunner.new.call`.

For the class-level API, `SeedRunner` uses `extend SomeModule`. This makes the
module's instance methods available as methods on the class itself, so the
existing `Seeding::SeedRunner.call` entry point can remain unchanged.

For example, the implemented shape is:

```ruby
module Seeding
  module DepartmentSteps
    def seed_departments
      # Move the current department-seeding behavior here.
    end
  end

  class SeedRunner
    extend DepartmentSteps

    def self.call
      departments = seed_departments
    end
  end
end
```

Each step has a distinct method name; using `call` for every extended module
would cause methods to override one another.

## Files changed for this refactor

| File | Planned change |
| --- | --- |
| `lib/seeding/department_command.rb` | Replaced the command class with `DepartmentSteps#seed_departments`, preserving department creation behavior. |
| `lib/seeding/location_command.rb` | Replaced the command class with `LocationSteps#seed_locations`, preserving Faker-generated address fields. |
| `lib/seeding/admin_user_command.rb` | Replaced the command class with `AdminUserSteps#seed_admin_user`, preserving password handling and its production check. |
| `lib/seeding/employee_command.rb` | Replaced the command class with `EmployeeSteps#seed_employees`, preserving batching and existing-data cleanup. |
| `lib/seeding/salary_command.rb` | Replaced the command class with `SalarySteps#seed_salaries`, preserving salary batching and persistence. |
| `lib/seeding/department_manager_command.rb` | Replaced the command class with `DepartmentManagerSteps#assign_department_managers`. |
| `lib/seeding/seed_runner.rb` | Kept required files, the `SeedRunner.call` API, profile validation, output, and execution order. Extended the step modules and called their uniquely named methods. |
| `test/lib/seeding/seed_runner_test.rb` | Kept profile handling coverage and the runner's public API test. |
| `test/lib/seeding/employee_command_test.rb` | Updated to call the new class-level step methods while preserving admin and employee/salary creation coverage. |
| `docs/seeding.md` | Updated the seeding overview to describe the step modules and class-level API. |

## Files that can remain as they are

- `lib/seeding/configuration.rb` is already a module and provides shared
  settings; it does not need to be included or extended to keep using
  `Configuration.for_profile` and its constants.
- `lib/seeding/employee_generator.rb` and
  `lib/seeding/salary_generator.rb` can remain class-level utility classes
  exposing `.call`. They generate attributes and are separate from the workflow
  steps.
- `lib/tasks/seeding.rake` can continue calling
  `Seeding::SeedRunner.call(profile: profile)`, so the command-line task
  interface does not need to change.
- `db/seeds.rb` can remain unchanged if it calls `Seeding::SeedRunner.call`.

## Loading and running

`extend` does not load a Ruby file. The runner still needs `require_relative`
for each step-module file (and any generator files used by those steps). The
Rake task then loads the runner and invokes the same public entry point:

```sh
bin/rails db:seed
bin/rails db:seed:small
```

The focused seeding tests should be run after changes. The dependency order is
departments and locations first, then admin and employees, followed by salaries
and department manager assignment.
