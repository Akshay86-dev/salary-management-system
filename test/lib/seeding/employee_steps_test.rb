# frozen_string_literal: true

require "test_helper"
require_relative "../../../lib/seeding/seed_runner"

class Seeding::EmployeeStepsTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  test "admin step uses the development password default" do
    previous_password = ENV.delete("SEED_ADMIN_PASSWORD")

    Seeding::SeedRunner.seed_admin_user

    admin = User.find_by!(email: "admin@salarymgmt.com")
    assert admin.valid_password?("password123")
  ensure
    ENV["SEED_ADMIN_PASSWORD"] = previous_password if previous_password
  end

  test "employee and salary steps can be rerun without duplicate profiles" do
    department = Department.create!(name: "Seed Test")
    location = Location.create!(name: "Seed Test", country: "USA")
    configuration = {
      employee_count: 2,
      employee_batch_size: 1,
      salary_batch_size: 2,
      salary_range: { min: 45_000, max: 45_000 }
    }
    Seeding::SeedRunner.seed_employees(
      configuration: configuration,
      departments: [ department ],
      locations: [ location ]
    )

    Seeding::SeedRunner.seed_employees(
      configuration: configuration,
      departments: [ department ],
      locations: [ location ]
    )
    Seeding::SeedRunner.seed_salaries(configuration: configuration)

    assert_equal 2, User.employee_records.count
    assert_equal 2, User.employee_records.distinct.count(:employee_id)
    assert_equal 2, Salary.base_salaries.count
    assert User.employee_records.all? { |user| user.encrypted_password.blank? }
  end
end
