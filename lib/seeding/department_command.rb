# frozen_string_literal: true

module Seeding
  class DepartmentCommand
    def call
      puts "\n1/6: Seeding #{Configuration::DEPARTMENT_NAMES.length} departments..."

      departments = Configuration::DEPARTMENT_NAMES.map do |name|
        department = Department.find_or_create_by!(name: name) do |record|
          record.budget = rand(500_000..5_000_000).to_f.round(2)
        end
        puts "  Created department: #{name}"
        department
      end

      puts "Departments seeded: #{departments.length} records"
      departments
    end
  end
end
