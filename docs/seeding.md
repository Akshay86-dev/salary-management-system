# Seed command organization

`db/seeds.rb` is intentionally small. It loads and invokes
`Seeding::SeedRunner`, which runs the seed commands in dependency order:

1. `DepartmentCommand`
2. `LocationCommand`
3. `AdminUserCommand`
4. `EmployeeCommand`
5. `SalaryCommand`
6. `DepartmentManagerCommand`

The commands live in `lib/seeding/`. Employee generation receives the seeded
departments and locations; salary generation runs after employee profiles
exist; manager assignment runs last. Shared data and batch settings live in
`configuration.rb`.

Run all seed steps with:

```sh
bin/rails db:seed
```

In development and test the HR admin seed password defaults to `password123`.
Production seeding requires `SEED_ADMIN_PASSWORD`. Seed employee and salary
data is regenerated on reruns; department and location records are
find-or-created.
