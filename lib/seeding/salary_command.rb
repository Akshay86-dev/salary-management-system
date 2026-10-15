# frozen_string_literal: true

module Seeding
  class SalaryCommand
    def initialize(configuration: Configuration::VALUES)
      @configuration = configuration
    end

    def call
      puts "\n5/6: Seeding salaries for employee profiles..."

      salaries = []
      batch_size = @configuration.fetch(:salary_batch_size)

      User.employee_records.find_each(batch_size: batch_size) do |employee|
        base_amount = random_salary_amount
        currency = Configuration::SALARY_CURRENCIES.sample

        salaries << salary_attributes(employee, base_amount, currency, :base, employee.hire_date, true)
        salaries << salary_attributes(employee, random_percentage(base_amount), Configuration::BONUS_CURRENCIES.sample,
                                      :bonus, employee.hire_date + rand(1..12).months, true) if rand < 0.15
        salaries << salary_attributes(employee, random_percentage(base_amount), currency,
                                      :commission, employee.hire_date + rand(0..6).months, [ true, false ].sample) if rand < 0.08
        salaries << salary_attributes(employee, base_amount * rand(1..5), "USD",
                                      :equity, employee.hire_date + rand(6..24).months, true) if rand < 0.05

        insert_batch(salaries) if salaries.length >= batch_size
      end

      insert_batch(salaries) if salaries.any?
      puts "Salaries seeded: #{Salary.count} records"
    end

    private

    def salary_attributes(employee, amount, currency, type, effective_date, current)
      {
        employee_id: employee.id,
        amount: amount,
        currency: currency,
        salary_type: Salary::SALARY_TYPES.fetch(type),
        effective_date: effective_date,
        is_current: current,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    def insert_batch(salaries)
      Salary.insert_all!(salaries)
      puts "  Progress: #{Salary.count} salary records created..."
      salaries.clear
    end

    def random_salary_amount
      rand(@configuration.dig(:salary_range, :min)..@configuration.dig(:salary_range, :max)).to_f.round(2)
    end

    def random_percentage(amount)
      (amount * rand(0.05..0.25)).round(2)
    end
  end
end
