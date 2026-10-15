require "test_helper"

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
      salary_type: Salary::SALARY_TYPES.fetch(:base),
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
    assert_equal 60_000.0, totals.dig("data", 0, "total_salary").to_f
    assert_equal "USD 60,000", totals.dig("data", 0, "formatted_total")
    assert_equal 60_000.0, totals.dig("summary", "total_all_departments").to_f

    get "/api/v1/reports/average_salary_by_job_title",
        headers: @authorization_headers,
        as: :json

    assert_response :ok
    averages = response.parsed_body
    assert_equal "Analyst", averages.dig("data", 0, "job_title")
    assert_equal 60_000.0, averages.dig("summary", "average_all_jobs").to_f
    assert_equal "$60,000.00", averages.dig("data", 0, "formatted_average")
  end
end
