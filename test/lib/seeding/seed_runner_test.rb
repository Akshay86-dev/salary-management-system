# frozen_string_literal: true

require "test_helper"
require_relative "../../../lib/seeding/seed_runner"

class Seeding::SeedRunnerTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  test "exposes seeding steps as class-level methods" do
    %i[
      seed_departments
      seed_locations
      seed_admin_user
      seed_employees
      seed_salaries
      assign_department_managers
    ].each do |step|
      assert_respond_to Seeding::SeedRunner, step
    end
  end

  test "blocks profile runs in production before seeding records" do
    production_environment = Struct.new(:production?).new(true)
    error = assert_raises(RuntimeError) do
      Seeding::SeedRunner.call(profile: :small, environment: production_environment)
    end

    assert_includes error.message, "disabled in production"
    assert_equal 0, Department.count
    assert_equal 0, Location.count
  end
end
