# frozen_string_literal: true

class Api::V1::DashboardController < Api::V1::BaseController
  def stats
    render json: {
      data: {
        total_departments: Department.count,
        total_employees: Employee.count,
        total_salaries: Salary.count
      }
    }
  end
end
