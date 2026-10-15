# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Salaries API", type: :request do
  let(:headers) { auth_headers }

  it "lists, filters, and shows salary records on the direct and nested routes" do
    employee = create_employee
    current = create_salary(employee:)
    historical = create_salary(employee:, amount: 55_000, is_current: false)

    get "/api/v1/salaries", headers: headers
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).dig("data").size).to eq(2)

    get "/api/v1/salaries", params: { employee_id: employee.id, active: "true" }, headers: headers
    expect(JSON.parse(response.body).dig("data").map { |item| item.fetch("id") })
      .to eq([ current.id.to_s ])

    get "/api/v1/salaries/#{current.id}", headers: headers
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).dig("data", "id")).to eq(current.id.to_s)

    get "/api/v1/employees/#{employee.id}/salaries", headers: headers
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).dig("data").map { |item| item.fetch("id") })
      .to contain_exactly(current.id.to_s, historical.id.to_s)

    get "/api/v1/employees/#{employee.id}/salaries/#{current.id}", headers: headers
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).dig("data", "id")).to eq(current.id.to_s)
  end

  it "creates salary records and reports invalid salary data" do
    employee = create_employee
    params = json_attributes(employee_id: employee.id, amount: 80_000, currency: "USD",
                             salary_type: Salary.salary_types.fetch("base"), effective_date: Date.current,
                             is_current: true)

    expect {
      post "/api/v1/salaries", params: params, headers: headers
    }.to change(Salary, :count).by(1)
    expect(response).to have_http_status(:created)
    expect(JSON.parse(response.body).dig("data", "attributes", "salary_type")).to eq(0)

    post "/api/v1/salaries", params: json_attributes(employee_id: employee.id, amount: -1,
                                                     currency: "usd", salary_type: 0,
                                                     effective_date: Date.current), headers: headers
    expect(response).to have_http_status(:unprocessable_content)
    expect(JSON.parse(response.body)).to have_key("errors")

    post "/api/v1/salaries", params: json_attributes(employee_id: employee.id, amount: 70_000,
                                                     currency: "USD", salary_type: 99,
                                                     effective_date: Date.current), headers: headers
    expect(response).to have_http_status(:unprocessable_content)
    expect(JSON.parse(response.body)).to have_key("errors")

    post "/api/v1/employees/#{employee.id}/salaries",
         params: json_attributes(employee_id: employee.id, amount: 82_000, currency: "USD",
                                 salary_type: Salary.salary_types.fetch("bonus"),
                                 effective_date: Date.current, is_current: true),
         headers: headers
    expect(response).to have_http_status(:created)
  end

  it "updates and destroys salary records on both route patterns" do
    employee = create_employee
    salary = create_salary(employee:)
    nested_salary = create_salary(employee:, amount: 10_000, salary_type: :bonus)

    patch "/api/v1/salaries/#{salary.id}", params: json_attributes(amount: 65_000), headers: headers
    expect(response).to have_http_status(:ok)
    expect(salary.reload.amount).to eq(65_000)

    put "/api/v1/employees/#{employee.id}/salaries/#{nested_salary.id}",
        params: json_attributes(amount: 12_000), headers: headers
    expect(response).to have_http_status(:ok)
    expect(nested_salary.reload.amount).to eq(12_000)

    expect {
      delete "/api/v1/salaries/#{salary.id}", headers: headers
    }.to change(Salary, :count).by(-1)
    expect(response).to have_http_status(:no_content)

    expect {
      delete "/api/v1/employees/#{employee.id}/salaries/#{nested_salary.id}", headers: headers
    }.to change(Salary, :count).by(-1)
    expect(response).to have_http_status(:no_content)
  end
end
