# frozen_string_literal: true

require "test_helper"

class Api::V1::EmployeesTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []

  test "creating an employee accepts the JSON API payload and creates its initial salary" do
    suffix = SecureRandom.hex(4)
    hr_user = User.create!(
      email: "hr-#{suffix}@example.com",
      password: "password123",
      first_name: "HR",
      last_name: "User",
      role: :human_resource
    )

    post "/api/v1/users/sign_in",
         params: { user: { email: hr_user.email, password: "password123" } },
         as: :json
    assert_response :ok
    token = response.parsed_body.dig("data", "token")

    department = Department.create!(name: "Employee test #{suffix}")
    location = Location.create!(name: "Employee test #{suffix}", country: "USA")
    existing_employee = User.create!(
      role: :employee,
      employee_id: "EMP-00042",
      first_name: "Existing",
      last_name: "Employee",
      email: "existing-#{suffix}@example.com",
      job_title: "Developer",
      hire_date: Date.current,
      department: department,
      location: location
    )

    post "/api/v1/employees",
         params: {
           data: {
             attributes: {
               first_name: "Test",
               last_name: "Employee",
               email: "employee-#{suffix}@example.com",
               job_title: "Developer",
               department_id: department.id,
               location_id: location.id,
               hire_date: Date.current,
               salary: 5_000
             }
           }
         },
         headers: { "Authorization" => "Bearer #{token}" },
         as: :json

    assert_response :created
    employee_id = response.parsed_body.dig("data", "id").to_i
    employee = User.find(employee_id)
    assert_equal "EMP-00043", employee.employee_id
    assert_equal "EMP-00042", existing_employee.reload.employee_id
    salary = Salary.find_by!(employee_id: employee_id)
    assert_equal 5_000, salary.amount.to_i
    assert_equal "base", salary.salary_type
  end
end
