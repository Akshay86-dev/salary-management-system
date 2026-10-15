# frozen_string_literal: true

require "test_helper"

class Api::V1::SalariesTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []

  setup do
    password = "password123"
    human_resource = User.create!(
      email: "hr-#{SecureRandom.hex(4)}@example.com",
      password: password,
      first_name: "HR",
      last_name: "User",
      role: :human_resource
    )

    post "/api/v1/users/sign_in",
         params: { user: { email: human_resource.email, password: password } },
         as: :json
    assert_response :ok
    @authorization_headers = {
      "Authorization" => "Bearer #{response.parsed_body.dig("data", "token")}"
    }

    suffix = SecureRandom.hex(4)
    @department = Department.create!(name: "Salary test #{suffix}")
    @location = Location.create!(name: "Salary test #{suffix}", country: "USA")
  end

  test "index filters by employee and active status and orders results by effective date" do
    employee = create_employee
    another_employee = create_employee
    active_salary = create_salary(employee, effective_date: Date.current, is_current: true)
    create_salary(employee, effective_date: Date.yesterday, is_current: false)
    newer_salary = create_salary(another_employee, effective_date: Date.tomorrow, is_current: true)

    get "/api/v1/salaries",
        params: { employee_id: employee.id, active: "true" },
        headers: @authorization_headers,
        as: :json

    assert_response :ok
    salaries = response.parsed_body.fetch("data")
    assert_equal [ active_salary.id.to_s ], salaries.map { |salary| salary.fetch("id") }

    get "/api/v1/salaries",
        params: { active: "true" },
        headers: @authorization_headers,
        as: :json

    assert_response :ok
    salaries = response.parsed_body.fetch("data")
    assert_equal [ newer_salary.id.to_s, active_salary.id.to_s ], salaries.map { |salary| salary.fetch("id") }
  end

  test "show returns the requested salary" do
    salary = create_salary(create_employee)

    get "/api/v1/salaries/#{salary.id}",
        headers: @authorization_headers,
        as: :json

    assert_response :ok
    assert_equal salary.id.to_s, response.parsed_body.dig("data", "id")
    assert_equal salary.employee_id, response.parsed_body.dig("data", "attributes", "employee_id")
  end

  test "create and update return serialized salary records" do
    employee = create_employee

    post "/api/v1/salaries",
         params: { data: { attributes: salary_attributes(employee) } },
         headers: @authorization_headers,
         as: :json

    assert_response :created
    salary_id = response.parsed_body.dig("data", "id")
    assert_equal employee.id, response.parsed_body.dig("data", "attributes", "employee_id")

    patch "/api/v1/salaries/#{salary_id}",
          params: { data: { attributes: { amount: 75_000 } } },
          headers: @authorization_headers,
          as: :json

    assert_response :ok
    assert_equal "75000.0", response.parsed_body.dig("data", "attributes", "amount")
  end

  test "create returns validation errors for invalid salary attributes" do
    employee = create_employee
    attributes = salary_attributes(employee).merge(amount: 0)

    post "/api/v1/salaries",
         params: { data: { attributes: attributes } },
         headers: @authorization_headers,
         as: :json

    assert_response :unprocessable_entity
    assert_includes response.parsed_body.fetch("errors"), "Amount must be greater than 0"
  end

  test "destroy removes the salary and returns no content" do
    salary = create_salary(create_employee)

    delete "/api/v1/salaries/#{salary.id}",
           headers: @authorization_headers,
           as: :json

    assert_response :no_content
    assert_not Salary.exists?(salary.id)
  end

  private

  def create_employee
    User.create!(
      role: :employee,
      first_name: "Salary",
      last_name: "Employee",
      email: "employee-#{SecureRandom.hex(4)}@example.com",
      job_title: "Developer",
      hire_date: Date.current,
      department: @department,
      location: @location
    )
  end

  def create_salary(employee, effective_date: Date.current, is_current: false)
    Salary.create!(
      employee: employee,
      amount: 50_000,
      currency: "USD",
      salary_type: Salary::SALARY_TYPES.fetch(:base),
      effective_date: effective_date,
      is_current: is_current
    )
  end

  def salary_attributes(employee)
    {
      employee_id: employee.id,
      amount: 60_000,
      currency: "USD",
      salary_type: Salary::SALARY_TYPES.fetch(:base),
      effective_date: Date.current,
      is_current: false
    }
  end
end
