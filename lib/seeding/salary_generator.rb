# frozen_string_literal: true

require_relative "configuration"

module Seeding
  class SalaryGenerator
    def self.call(employee, configuration: Configuration::VALUES)
      base_amount = random_salary_amount(configuration)
      currency = Configuration::SALARY_CURRENCIES.sample

      salaries = [
        salary_attributes(employee, base_amount, currency, :base, employee.hire_date, true)
      ]
      salaries << salary_attributes(employee, random_percentage(base_amount), Configuration::BONUS_CURRENCIES.sample,
                                    :bonus, employee.hire_date + rand(1..12).months, true) if rand < 0.15
      salaries << salary_attributes(employee, random_percentage(base_amount), currency,
                                    :commission, employee.hire_date + rand(0..6).months, [ true, false ].sample) if rand < 0.08
      salaries << salary_attributes(employee, base_amount * rand(1..5), "USD",
                                    :equity, employee.hire_date + rand(6..24).months, true) if rand < 0.05
      salaries
    end

    def self.salary_attributes(employee, amount, currency, type, effective_date, current)
      {
        employee_id: employee.id,
        amount: amount,
        currency: currency,
        salary_type: type,
        effective_date: effective_date,
        is_current: current,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    def self.random_salary_amount(configuration)
      rand(configuration.dig(:salary_range, :min)..configuration.dig(:salary_range, :max)).to_f.round(2)
    end

    def self.random_percentage(amount)
      (amount * rand(0.05..0.25)).round(2)
    end

    private_class_method :salary_attributes, :random_salary_amount, :random_percentage
  end
end
