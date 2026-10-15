# frozen_string_literal: true

require_relative "salary_generator"

module Seeding
  module SalarySteps
    def seed_salaries(configuration: Configuration::VALUES)
      puts "\n5/6: Seeding salaries for employee profiles..."

      salaries = []
      batch_size = configuration.fetch(:salary_batch_size)

      User.employee_records.find_each(batch_size: batch_size) do |employee|
        salaries.concat(SalaryGenerator.call(employee, configuration: configuration))

        insert_batch(salaries) if salaries.length >= batch_size
      end

      insert_batch(salaries) if salaries.any?
      puts "Salaries seeded: #{Salary.count} records"
    end

    private

    def insert_batch(salaries)
      Salary.insert_all!(salaries)
      puts "  Progress: #{Salary.count} salary records created..."
      salaries.clear
    end
  end
end
