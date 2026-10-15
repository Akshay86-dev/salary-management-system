# frozen_string_literal: true

require "test_helper"

class Api::V1::DashboardTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []

  test "dashboard returns employee distributions by department and country" do
    suffix = SecureRandom.hex(4)
    hr_user = User.create!(
      email: "dashboard-hr-#{suffix}@example.com",
      password: "password123",
      first_name: "Dashboard",
      last_name: "HR",
      role: :human_resource
    )

    post "/api/v1/users/sign_in",
         params: { user: { email: hr_user.email, password: "password123" } },
         as: :json
    token = response.parsed_body.dig("data", "token")

    department = Department.create!(name: "Dashboard #{suffix}")
    location = Location.create!(name: "Dashboard #{suffix}", country: "Canada")
    User.create!(
      role: :employee,
      first_name: "Dashboard",
      last_name: "Employee",
      email: "dashboard-employee-#{suffix}@example.com",
      job_title: "Analyst",
      hire_date: Date.current,
      department: department,
      location: location
    )

    get "/api/v1/dashboard/stats",
        headers: { "Authorization" => "Bearer #{token}" },
        as: :json

    assert_response :ok
    data = response.parsed_body.fetch("data")
    assert_equal 1, data.fetch("total_countries")
    assert_includes data.fetch("employees_by_department"), { "name" => department.name, "count" => 1 }
    assert_includes data.fetch("employees_by_country"), { "name" => "Canada", "count" => 1 }
  end
end
