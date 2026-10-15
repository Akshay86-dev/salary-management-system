# frozen_string_literal: true

require "faker"
require_relative "configuration"

module Seeding
  class EmployeeGenerator
    def self.call(departments:, locations:, index:, used_employee_ids:)
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
        department_id: departments.sample.id,
        location_id: locations.sample.id,
        is_active: [ true, true, true, false ].sample,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    def self.next_employee_id(number, used_employee_ids)
      loop do
        raise "Employee ID limit reached (EMP-99999)." if number > 99_999

        employee_id = "EMP-#{number.to_s.rjust(5, '0')}"
        return employee_id unless used_employee_ids.key?(employee_id)

        number += 1
      end
    end
    private_class_method :next_employee_id
  end
end
