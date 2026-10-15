# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Departments API", type: :request do
  let(:headers) { auth_headers }

  it "lists and shows departments" do
    department = create_department

    get "/api/v1/departments", headers: headers
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).dig("data").map { |item| item.dig("attributes", "name") })
      .to include(department.name)

    get "/api/v1/departments/#{department.id}", headers: headers
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).dig("data", "id")).to eq(department.id.to_s)
  end

  it "creates departments and returns validation errors for invalid data" do
    expect {
      post "/api/v1/departments", params: json_attributes(name: "Finance"), headers: headers
    }.to change(Department, :count).by(1)
    expect(response).to have_http_status(:created)

    post "/api/v1/departments", params: json_attributes(name: ""), headers: headers
    expect(response).to have_http_status(:unprocessable_content)
    expect(JSON.parse(response.body)).to have_key("errors")
  end

  it "updates and deletes departments" do
    department = create_department

    patch "/api/v1/departments/#{department.id}", params: json_attributes(name: "People"), headers: headers
    expect(response).to have_http_status(:ok)
    expect(department.reload.name).to eq("People")

    put "/api/v1/departments/#{department.id}", params: json_attributes(name: "Talent"), headers: headers
    expect(response).to have_http_status(:ok)
    expect(department.reload.name).to eq("Talent")

    expect {
      delete "/api/v1/departments/#{department.id}", headers: headers
    }.to change(Department, :count).by(-1)
    expect(response).to have_http_status(:no_content)
  end
end
