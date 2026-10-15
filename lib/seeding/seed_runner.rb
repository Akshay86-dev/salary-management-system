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
    def run
      puts "Starting database seeding..."
      puts "Target counts: #{Configuration::VALUES.fetch(:employee_count)} employees"
      puts "=" * 60

      departments = DepartmentCommand.new.call
      locations = LocationCommand.new.call
      AdminUserCommand.new.call
      EmployeeCommand.new(departments: departments, locations: locations).call
      SalaryCommand.new.call
      DepartmentManagerCommand.new.call

      print_summary
    end

    private

    def print_summary
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
