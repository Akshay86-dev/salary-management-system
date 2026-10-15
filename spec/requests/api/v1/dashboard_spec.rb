# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard API", type: :request do
  it "returns department, employee, and country statistics" do
    department = create_department
    location = create_location(country: "Canada")
    create_employee(department:, location:)

    get "/api/v1/dashboard/stats", headers: auth_headers

    body = JSON.parse(response.body).dig("data")
    expect(response).to have_http_status(:ok)
    expect(body).to include("total_departments" => 1, "total_employees" => 1, "total_countries" => 1)
    expect(body.fetch("employees_by_department")).to include("name" => department.name, "count" => 1)
    expect(body.fetch("employees_by_country")).to include("name" => "Canada", "count" => 1)
  end
end
