# frozen_string_literal: true

# API v1 Reports Controller
# Provides reporting and analytics endpoints for salary data
class Api::V1::ReportsController < Api::V1::BaseController
  # GET /api/v1/reports/salary_totals
  # Total salary amounts by department
  def salary_totals_by_department
    totals = current_salaries_for_reporting
      .group("departments.name")
      .sum(:amount)
    total_all_departments = totals.values.sum

    result = totals.map do |dept_name, total|
      {
        department: dept_name,
        total_salary: total,
        formatted_total: format_salary(total)
      }
    end

    render json: {
      data: result,
      summary: {
        total_all_departments: total_all_departments,
        formatted_total: format_salary(total_all_departments),
        department_count: totals.size
      }
    }
  end

  # GET /api/v1/reports/average_salary_by_job_title
  # Average salary by job title
  def average_salary_by_job_title
    averages = current_salaries_for_reporting
      .group("users.job_title")
      .average(:amount)
    average_all_jobs = averages.values.sum / averages.size.to_f

    result = averages.map do |job_title, avg_salary|
      {
        job_title: job_title,
        average_salary: avg_salary.to_f,
        formatted_average: format_currency(avg_salary.to_f)
      }
    end

    render json: {
      data: result.sort_by { |d| -d[:average_salary] },
      summary: {
        average_all_jobs: average_all_jobs,
        formatted_average: format_currency(average_all_jobs),
        job_title_count: averages.size
      }
    }
  end

  # GET /api/v1/reports/department_comparison
  # Compare departments by average salary
  def department_comparison
    departments = Department.includes(:employees)

    result = departments.map do |dept|
      active_employees = dept.employees.active
      salaries = Salary.where(employee_id: active_employees.select(&:id), is_current: true)
      total_salary = salaries.sum(:amount)
      avg_salary = salaries.average(:amount) || 0

      {
        department: dept.name,
        budget: dept.budget,
        employee_count: active_employees.count,
        total_salary: total_salary,
        average_salary: avg_salary.to_f,
        formatted_total_salary: format_currency(total_salary),
        formatted_average_salary: format_currency(avg_salary.to_f)
      }
    end

    render json: {
      data: result.sort_by { |d| -d[:employee_count] },
      summary: {
        total_employees: result.sum { |d| d[:employee_count] },
        total_salary: result.sum { |d| d[:total_salary] },
        formatted_total_salary: format_currency(result.sum { |d| d[:total_salary] }),
        department_count: result.size
      }
    }
  end

  # GET /api/v1/reports/salary_by_currency
  # Salary totals grouped by currency
  def salary_by_currency
    currency_data = Salary
      .where(is_current: true)
      .group(:currency)
      .sum(:amount)

    result = currency_data.map do |currency, total|
      {
        currency: currency,
        total_amount: total,
        formatted_total: format_salary(total, currency)
      }
    end

    render json: { data: result }
  end

  # GET /api/v1/reports/export_salaries
  # Export salary data as CSV
  def export_salaries
    salaries = Salary.includes(employee: [ :department, :location ])
                     .active_salaries
                     .order("users.last_name", "users.first_name")

    csv_data = CSV.generate(headers: true) do |csv|
      csv << %w[Employee ID Name Email Department Job Title Salary Amount Currency Type Effective Date]

      salaries.find_each do |salary|
        employee = salary.employee
        csv << [
          employee&.employee_id,
          employee&.full_name,
          employee&.email,
          employee&.department&.name,
          employee&.job_title,
          Salary::SALARY_TYPES.key(salary.salary_type)&.to_s&.upcase,
          salary.amount,
          salary.currency,
          Salary::SALARY_TYPES.key(salary.salary_type)&.to_s&.upcase,
          salary.effective_date.strftime("%Y-%m-%d")
        ]
      end
    end

    send_data csv_data,
              filename: "salary_report_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv",
              type: "text/csv",
              disposition: "attachment"
  end

  # GET /api/v1/reports/export_employees
  # Export employee data as CSV
  def export_employees
    employees = User.employee_records.includes(:department, :location, :salaries)
                     .ordered

    csv_data = CSV.generate(headers: true) do |csv|
      csv << %w[Employee ID Name Email Job Title Hire Date Department Location Status Current Salary]

      employees.find_each do |employee|
        current_salary = employee.current_salary
        csv << [
          employee.employee_id,
          employee.full_name,
          employee.email,
          employee.job_title,
          employee.hire_date.strftime("%Y-%m-%d"),
          employee.department&.name,
          employee.location&.name,
          employee.is_active ? "Active" : "Inactive",
          current_salary ? "#{current_salary.currency} #{current_salary.amount}" : nil
        ]
      end
    end

    send_data csv_data,
              filename: "employee_report_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv",
              type: "text/csv",
              disposition: "attachment"
  end

  private

  def current_salaries_for_reporting
    Salary.joins(employee: :department).where(is_current: true)
  end

  def format_salary(amount, currency = "USD")
    "#{currency} #{number_with_delimiter(amount.to_i)}"
  end

  def format_currency(amount)
    return "$0.00" if amount.nil?

    "$#{number_with_delimiter(number_with_precision(amount, precision: 2))}"
  end

  def number_with_delimiter(number)
    ActiveSupport::NumberHelper.number_to_delimited(number)
  end

  def number_with_precision(number, precision: 2)
    sprintf("%.#{precision}f", number)
  end
end
