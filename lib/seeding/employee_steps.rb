# frozen_string_literal: true

require_relative "employee_generator"

module Seeding
  module EmployeeSteps
    def seed_employees(configuration: Configuration::VALUES, departments:, locations:)
      raise "Seed departments and locations before employees." if departments.empty? || locations.empty?

      count = configuration.fetch(:employee_count)
      puts "\n4/6: Seeding #{count} employees..."
      clear_existing_employee_data

      used_employee_ids = User.employee_records.pluck(:employee_id).to_h { |employee_id| [ employee_id, true ] }
      created_count = 0
      batch_size = configuration.fetch(:employee_batch_size)

      (0...count).step(batch_size) do |start_index|
        end_index = [ start_index + batch_size - 1, count - 1 ].min
        employees = (start_index..end_index).map do |index|
          EmployeeGenerator.call(
            departments: departments,
            locations: locations,
            index: index,
            used_employee_ids: used_employee_ids
          )
        end

        User.insert_all!(employees)
        created_count += employees.length
        puts "  Progress: #{created_count}/#{count} employees created..."
      end

      puts "Employees seeded: #{User.employee_records.count} records"
    end

    private

    def clear_existing_employee_data
      return unless User.employee_records.exists?

      puts "  Clearing existing employees..."
      Department.update_all(manager_id: nil)
      Salary.delete_all
      User.where(role: :employee).delete_all
    end
  end
end
