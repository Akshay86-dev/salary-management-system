# frozen_string_literal: true

class Api::V1::DashboardController < Api::V1::BaseController
  def stats
    employee_records = User.employee_records
    employees_by_department = employee_records
      .joins(:department)
      .group("departments.name")
      .order("departments.name")
      .count
      .map { |name, count| { name: name, count: count } }
    employees_by_country = employee_records
      .joins(:location)
      .where.not(locations: { country: [ nil, "" ] })
      .group("locations.country")
      .order("locations.country")
      .count
      .map { |name, count| { name: name, count: count } }

    render json: {
      data: {
        total_departments: Department.count,
        total_employees: employee_records.count,
        total_countries: employees_by_country.size,
        employees_by_department: employees_by_department,
        employees_by_country: employees_by_country
      }
    }
  end
end
