# frozen_string_literal: true

# API v1 Reports Controller
# Provides reporting and analytics endpoints for salary data
class Api::V1::ReportsController < Api::V1::BaseController
  # GET /api/v1/reports/salary_totals
  # Total salary amounts by department
  def salary_totals_by_department
    totals = current_salaries_for_reporting
      .group("departments.name", "salaries.currency")
      .sum(:amount)

    result = totals.map do |(dept_name, currency), total|
      {
        department: dept_name,
        currency: currency,
        total_salary: total,
        formatted_total: format_salary(total, currency)
      }
    end

    render json: {
      data: result,
      summary: {
        totals_by_currency: format_totals_by_currency(totals),
        department_count: totals.keys.map(&:first).uniq.size
      }
    }
  end

  # GET /api/v1/reports/average_salary_by_job_title
  # Average salary by job title
  def average_salary_by_job_title
    salaries = current_salaries_for_reporting
    averages = salaries.group("users.job_title", "salaries.currency").average(:amount)
    averages_by_currency = salaries.group("salaries.currency").average(:amount)

    result = averages.map do |(job_title, currency), avg_salary|
      {
        job_title: job_title,
        currency: currency,
        average_salary: avg_salary.to_f,
        formatted_average: format_salary(avg_salary, currency)
      }
    end

    render json: {
      data: result.sort_by { |d| -d[:average_salary] },
      summary: {
        averages_by_currency: averages_by_currency.map do |currency, average|
          {
            currency: currency,
            average_salary: average.to_f,
            formatted_average: format_salary(average, currency)
          }
        end,
        job_title_count: averages.keys.map(&:first).uniq.size
      }
    }
  end

  # GET /api/v1/reports/department_comparison
  # Compare departments by average salary
  def department_comparison
    departments = Department.ordered.includes(:employees)

    result = departments.map do |dept|
      active_employees = dept.employees.active
      salaries = Salary.where(employee_id: active_employees.select(:id), is_current: true)
      salary_by_currency = salaries.group(:currency).sum(:amount).map do |currency, total|
        average = salaries.where(currency: currency).average(:amount) || 0

        {
          currency: currency,
          total_salary: total,
          average_salary: average.to_f,
          formatted_total_salary: format_salary(total, currency),
          formatted_average_salary: format_salary(average, currency)
        }
      end

      {
        department: dept.name,
        budget: dept.budget,
        employee_count: active_employees.count,
        salary_by_currency: salary_by_currency
      }
    end

    totals_by_currency = Salary.joins(employee: :department)
      .where(is_current: true, users: { is_active: true })
      .group(:currency)
      .sum(:amount)

    render json: {
      data: result.sort_by { |d| -d[:employee_count] },
      summary: {
        total_employees: result.sum { |d| d[:employee_count] },
        totals_by_currency: format_totals_by_currency(totals_by_currency),
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
      csv << [ "Employee ID", "Name", "Email", "Department", "Job Title", "Salary Type",
               "Salary Amount", "Currency", "Effective Date" ]

      salaries.find_each do |salary|
        employee = salary.employee
        csv << [
          employee&.employee_id,
          employee&.full_name,
          employee&.email,
          employee&.department&.name,
          employee&.job_title,
          salary.salary_type.upcase,
          salary.amount,
          salary.currency,
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
    ActiveSupport::NumberHelper.number_to_currency(
      amount,
      unit: "#{currency} ",
      format: "%u%n",
      precision: 2
    )
  end

  def format_totals_by_currency(totals)
    totals.group_by do |key, _amount|
      key.is_a?(Array) ? key.last : key
    end.map do |currency, entries|
      amount = entries.sum { |_key, value| value }

      {
        currency: currency,
        total_salary: amount,
        formatted_total: format_salary(amount, currency)
      }
    end
  end
end
