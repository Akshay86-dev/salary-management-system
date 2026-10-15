# This file should ensure the existence of records required to run the application.
# It should be safe to execute with `bin/rails db:seed`.

require_relative "../lib/seeding/seed_runner"

Seeding::SeedRunner.call(profile: :default)
