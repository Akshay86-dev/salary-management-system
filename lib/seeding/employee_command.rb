# frozen_string_literal: true

module Seeding
  class EmployeeCommand
    def initialize(configuration: Configuration::VALUES, departments:, locations:)
      @configuration = configuration
      @departments = departments
      @locations = locations
    end

    def call
      raise "Seed departments and locations before employees." if @departments.empty? || @locations.empty?

      count = @configuration.fetch(:employee_count)
      puts "\n4/6: Seeding #{count} employees..."
      clear_existing_employee_data

      used_employee_ids = User.employee_records.pluck(:employee_id).to_h { |employee_id| [ employee_id, true ] }
      created_count = 0
      batch_size = @configuration.fetch(:employee_batch_size)

      (0...count).step(batch_size) do |start_index|
        end_index = [ start_index + batch_size - 1, count - 1 ].min
        employees = (start_index..end_index).map do |index|
          employee_attributes(index, used_employee_ids)
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

    def employee_attributes(index, used_employee_ids)
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name

      {
        role: "EMPLOYEE",
        first_name: first_name,
        last_name: last_name,
        email: Faker::Internet.email(name: "#{first_name} #{last_name}"),
        employee_id: next_employee_id(index + 1, used_employee_ids),
        job_title: Configuration::JOB_TITLES.sample,
        hire_date: Faker::Date.between(from: 5.years.ago, to: Date.current),
        department_id: @departments.sample.id,
        location_id: @locations.sample.id,
        is_active: [ true, true, true, false ].sample,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    def next_employee_id(number, used_employee_ids)
      loop do
        raise "Employee ID limit reached (EMP-99999)." if number > 99_999

        employee_id = "EMP-#{number.to_s.rjust(5, '0')}"
        return employee_id unless used_employee_ids.key?(employee_id)

        number += 1
      end
    end
  end
end
