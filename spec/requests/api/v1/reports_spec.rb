# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe "Reports API", type: :request do
  let(:headers) { auth_headers }
  let!(:department) { create_department(name: "Research") }
  let!(:location) { create_location }
  let!(:employee) { create_employee(department:, location:, job_title: "Researcher") }

  before { create_salary(employee:, amount: 90_000) }

  it "reports salary totals, averages, department comparisons, and currency totals" do
    get "/api/v1/reports/salary_totals_by_department", headers: headers
    body = JSON.parse(response.body)
    expect(response).to have_http_status(:ok)
    expect(body.dig("data").first).to include("department", "currency", "total_salary", "formatted_total")
    expect(body.dig("summary", "totals_by_currency").first).to include("currency", "total_salary")

    get "/api/v1/reports/average_salary_by_job_title", headers: headers
    body = JSON.parse(response.body)
    expect(response).to have_http_status(:ok)
    expect(body.dig("data").first).to include("job_title", "currency", "average_salary", "formatted_average")
    expect(body.dig("summary", "job_title_count")).to eq(1)

    get "/api/v1/reports/department_comparison", headers: headers
    body = JSON.parse(response.body)
    expect(response).to have_http_status(:ok)
    expect(body.dig("data").first).to include("department", "employee_count", "salary_by_currency")
    expect(body.dig("data").first.fetch("salary_by_currency").first).to include("currency", "average_salary")
    expect(body.dig("summary", "total_employees")).to eq(1)

    get "/api/v1/reports/salary_by_currency", headers: headers
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).dig("data").first).to include("currency", "total_amount")
  end

  it "exports salaries and employees as CSV attachments" do
    get "/api/v1/reports/export_salaries", headers: headers
    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("text/csv")
    csv = CSV.parse(response.body, headers: true)
    expect(csv.headers).to eq([
      "Employee ID", "Name", "Email", "Department", "Job Title", "Salary Type",
      "Salary Amount", "Currency", "Effective Date"
    ])
    expect(csv.first["Email"]).to eq(employee.email)
    expect(csv.first["Salary Amount"]).to eq("90000.0")

    get "/api/v1/reports/export_employees", headers: headers
    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("text/csv")
    expect(CSV.parse(response.body).last).to include(employee.email, "Researcher")
  end
end
