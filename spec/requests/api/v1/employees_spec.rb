# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Employees API", type: :request do
  let(:headers) { auth_headers }

  it "lists, filters, paginates, and shows employees" do
    department = create_department
    location = create_location
    active = create_employee(department:, location:, first_name: "Avery", last_name: "Active")
    inactive = create_employee(department:, location:, first_name: "Riley", last_name: "Inactive",
                               is_active: false)

    get "/api/v1/employees", headers: headers
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).dig("data").size).to eq(2)

    get "/api/v1/employees", params: { status: "active", query: "avery", department_id: department.id,
                                      country: "USA", page: 1, per_page: 1 }, headers: headers
    body = JSON.parse(response.body)
    expect(response).to have_http_status(:ok)
    expect(body.dig("data").map { |item| item.fetch("id") }).to eq([ active.id.to_s ])
    expect(body.dig("meta", "total_count")).to eq(1)

    get "/api/v1/employees", params: { status: "inactive" }, headers: headers
    expect(JSON.parse(response.body).dig("data").map { |item| item.fetch("id") }).to eq([ inactive.id.to_s ])

    get "/api/v1/employees/#{active.id}", headers: headers
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).dig("data", "attributes", "full_name")).to eq("Avery Active")
  end

  it "rejects invalid pagination parameters" do
    [ { page: 0 }, { page: "abc" }, { per_page: 101 }, { per_page: "1.5" } ].each do |params|
      get "/api/v1/employees", params:, headers: headers

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to have_key("error")
    end
  end

  it "creates an employee with an optional starting salary and rejects invalid employees" do
    department = create_department
    location = create_location
    params = json_attributes(first_name: "Sam", last_name: "New", email: "sam-new@example.com",
                             job_title: "Analyst", hire_date: Date.current, department_id: department.id,
                             location_id: location.id, salary: 72_000)
    request_headers = headers

    expect {
      post "/api/v1/employees", params: params, headers: request_headers
    }.to change(User, :count).by(1).and change(Salary, :count).by(1)
    expect(response).to have_http_status(:created)
    expect(Salary.order(:id).last.amount).to eq(72_000)

    post "/api/v1/employees",
         params: json_attributes(first_name: "", last_name: "Bad", email: "bad@example.com",
                                 job_title: "Analyst", hire_date: Date.current,
                                 department_id: department.id, location_id: location.id),
         headers: request_headers
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "creates employees without a starting salary" do
    department = create_department
    location = create_location
    params = json_attributes(first_name: "Jamie", last_name: "New", email: "jamie-new@example.com",
                             job_title: "Analyst", hire_date: Date.current, department_id: department.id,
                             location_id: location.id)
    request_headers = headers

    expect {
      post "/api/v1/employees", params:, headers: request_headers
    }.to change(User, :count).by(1).and change(Salary, :count).by(0)
    expect(response).to have_http_status(:created)
  end

  it "rolls back employee creation when its starting salary is invalid" do
    department = create_department
    location = create_location
    params = json_attributes(first_name: "Casey", last_name: "New", email: "casey-new@example.com",
                             job_title: "Analyst", hire_date: Date.current, department_id: department.id,
                             location_id: location.id, salary: -1)
    request_headers = headers

    expect {
      post "/api/v1/employees", params:, headers: request_headers
    }.not_to change(User, :count)
    expect(response).to have_http_status(:unprocessable_content)
    expect(JSON.parse(response.body)).to have_key("errors")
  end

  it "updates an employee and soft deletes them" do
    employee = create_employee

    patch "/api/v1/employees/#{employee.id}", params: json_attributes(job_title: "Lead"), headers: headers
    expect(response).to have_http_status(:ok)
    expect(employee.reload.job_title).to eq("Lead")

    put "/api/v1/employees/#{employee.id}", params: json_attributes(is_active: false), headers: headers
    expect(response).to have_http_status(:ok)
    expect(employee.reload).not_to be_active

    expect {
      delete "/api/v1/employees/#{employee.id}", headers: headers
    }.not_to change(User, :count)
    expect(response).to have_http_status(:no_content)
    expect(employee.reload).not_to be_active
  end

  it "returns validation errors when an employee update is invalid" do
    employee = create_employee

    patch "/api/v1/employees/#{employee.id}", params: json_attributes(email: ""), headers: headers

    expect(response).to have_http_status(:unprocessable_content)
    expect(JSON.parse(response.body)).to have_key("errors")
    expect(employee.reload.email).not_to be_blank
  end

  it "filters by active flag, search fields, department, and country" do
    department = create_department
    location = create_location(country: "Canada")
    employee = create_employee(department:, location:, first_name: "Robin", last_name: "Searchable",
                               job_title: "Data Analyst")
    create_employee(department: create_department, location: create_location(country: "USA"),
                    first_name: "Robin", last_name: "Inactive", is_active: false)

    [
      { active: "true", query: employee.email },
      { query: employee.employee_id },
      { query: "data analyst" }
    ].each do |params|
      get "/api/v1/employees", params:, headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).dig("data").map { |item| item.fetch("id") }).to eq([ employee.id.to_s ])
    end

    get "/api/v1/employees", params: { department_id: department.id }, headers: headers
    expect(JSON.parse(response.body).dig("data").map { |item| item.fetch("id") }).to eq([ employee.id.to_s ])

    get "/api/v1/employees", params: { country: "Canada" }, headers: headers
    expect(JSON.parse(response.body).dig("data").map { |item| item.fetch("id") }).to eq([ employee.id.to_s ])
  end

  it "returns the requested page and pagination metadata" do
    department = create_department
    location = create_location
    first = create_employee(department:, location:, first_name: "A", last_name: "Able")
    second = create_employee(department:, location:, first_name: "B", last_name: "Baker")

    get "/api/v1/employees", params: { page: 2, per_page: 1 }, headers: headers

    body = JSON.parse(response.body)
    expect(response).to have_http_status(:ok)
    expect(body.dig("data").map { |item| item.fetch("id") }).to eq([ second.id.to_s ])
    expect(body.fetch("meta")).to include(
      "current_page" => 2,
      "per_page" => 1,
      "total_count" => 2,
      "total_pages" => 2
    )
  end
end
