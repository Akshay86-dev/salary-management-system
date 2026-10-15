# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication API", type: :request do
  it "returns the authenticated user's profile" do
    user = create_human_resource

    get "/api/v1/auth/profile", headers: auth_headers(user)

    body = JSON.parse(response.body).dig("data")
    expect(response).to have_http_status(:ok)
    expect(body).to include("id" => user.id, "type" => "user")
    expect(body.dig("attributes", "email")).to eq(user.email)
    expect(body.dig("attributes", "role")).to eq("HUMAN_RESOURCE")
  end

  it "requires authentication and rejects non-HR users" do
    get "/api/v1/auth/profile"
    expect(response).to have_http_status(:forbidden)

    get "/api/v1/auth/profile", headers: auth_headers(create_employee)
    expect(response).to have_http_status(:unauthorized)
  end
end
