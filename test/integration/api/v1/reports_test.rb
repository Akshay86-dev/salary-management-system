require "test_helper"
require "csv"

class Api::V1::ReportsTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []

  setup do
    user = User.create!(
      email: "reports-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      first_name: "Reports",
      last_name: "Test",
      role: :human_resource
    )

    post "/api/v1/users/sign_in",
         params: { user: { email: user.email, password: "password123" } },
         as: :json
    @authorization_headers = {
      "Authorization" => "Bearer #{response.parsed_body.dig("data", "token")}"
    }

    department = Department.create!(name: "Reports #{SecureRandom.hex(4)}")
    location = Location.create!(name: "Reports", country: "USA")
    @employee = User.create!(
      role: :employee,
      first_name: "Report",
      last_name: "Employee",
      email: "report-employee-#{SecureRandom.hex(4)}@example.com",
      job_title: "Analyst",
      hire_date: Date.current,
      department: department,
      location: location
    )
    @employee.salaries.create!(
      amount: 60_000,
      currency: "USD",
      salary_type: :base,
      effective_date: Date.current,
      is_current: true
    )

    euro_employee = User.create!(
      role: :employee,
      first_name: "Euro",
      last_name: "Employee",
      email: "euro-employee-#{SecureRandom.hex(4)}@example.com",
      job_title: "Analyst",
      hire_date: Date.current,
      department: @employee.department,
      location: @employee.location
    )
    euro_employee.salaries.create!(
      amount: 50_000,
      currency: "EUR",
      salary_type: :base,
      effective_date: Date.current,
      is_current: true
    )
  end

  test "salary reports share current-salary filtering and preserve their summaries" do
    get "/api/v1/reports/salary_totals_by_department",
        headers: @authorization_headers,
        as: :json

    assert_response :ok
    totals = response.parsed_body
    totals_by_currency = totals.fetch("data").index_by { |entry| entry.fetch("currency") }
    assert_equal 60_000.0, totals_by_currency.dig("USD", "total_salary").to_f
    assert_equal 50_000.0, totals_by_currency.dig("EUR", "total_salary").to_f
    assert_equal "USD 60,000.00", totals_by_currency.dig("USD", "formatted_total")
    summary_by_currency = totals.dig("summary", "totals_by_currency").index_by { |entry| entry.fetch("currency") }
    assert_equal 60_000.0, summary_by_currency.dig("USD", "total_salary").to_f
    assert_equal 50_000.0, summary_by_currency.dig("EUR", "total_salary").to_f

    get "/api/v1/reports/average_salary_by_job_title",
        headers: @authorization_headers,
        as: :json

    assert_response :ok
    averages = response.parsed_body
    averages_by_currency = averages.fetch("data").index_by { |entry| entry.fetch("currency") }
    assert_equal "Analyst", averages_by_currency.dig("USD", "job_title")
    assert_equal 60_000.0, averages_by_currency.dig("USD", "average_salary").to_f
    assert_equal 50_000.0, averages_by_currency.dig("EUR", "average_salary").to_f
    assert_equal "USD 60,000.00", averages_by_currency.dig("USD", "formatted_average")

    get "/api/v1/reports/department_comparison",
        headers: @authorization_headers,
        as: :json

    assert_response :ok
    comparison = response.parsed_body.dig("data", 0)
    comparison_by_currency = comparison.fetch("salary_by_currency").index_by { |entry| entry.fetch("currency") }
    assert_equal 60_000.0, comparison_by_currency.dig("USD", "total_salary").to_f
    assert_equal 50_000.0, comparison_by_currency.dig("EUR", "total_salary").to_f

    get "/api/v1/reports/export_salaries",
        headers: @authorization_headers,
        as: :json

    assert_response :ok
    rows = CSV.parse(response.body, headers: true)
    assert_equal [
      "Employee ID", "Name", "Email", "Department", "Job Title", "Salary Type",
      "Salary Amount", "Currency", "Effective Date"
    ], rows.headers
    salary_row = rows.find { |row| row["Email"] == @employee.email }
    assert_equal "60000.0", salary_row["Salary Amount"]
    assert_equal "USD", salary_row["Currency"]
    assert_equal "BASE", salary_row["Salary Type"]
  end
end
