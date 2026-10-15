# frozen_string_literal: true

require "faker"
require_relative "configuration"
require_relative "department_command"
require_relative "location_command"
require_relative "admin_user_command"
require_relative "employee_command"
require_relative "salary_command"
require_relative "department_manager_command"

module Seeding
  class SeedRunner
    extend DepartmentSteps
    extend LocationSteps
    extend AdminUserSteps
    extend EmployeeSteps
    extend SalarySteps
    extend DepartmentManagerSteps

    def self.call(profile: :default, environment: Rails.env)
      configuration = Configuration.for_profile(profile)
      raise "Seed profiles are disabled in production because employee and salary records are regenerated." if environment.production?

      puts "Starting '#{profile}' database seed profile..."
      puts "Target counts: #{configuration.fetch(:employee_count)} employees"
      puts "=" * 60

      departments = seed_departments
      locations = seed_locations

      seed_admin_user
      seed_employees(configuration: configuration, departments: departments, locations: locations)
      seed_salaries(configuration: configuration)
      assign_department_managers

      puts "\n" + "=" * 60
      puts "DATABASE SEEDING COMPLETE!"
      puts "=" * 60
      puts "Departments: #{Department.count}"
      puts "Locations: #{Location.count}"
      puts "Employees: #{User.employee_records.count}"
      puts "Active Employees: #{User.active.count}"
      puts "Inactive Employees: #{User.inactive.count}"
      puts "Salaries: #{Salary.count}"
      puts "Current Salaries: #{Salary.active_salaries.count}"
      puts "Users: #{User.count}"
      puts "=" * 60
    end
  end
end
