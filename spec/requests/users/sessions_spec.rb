# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User session endpoints", type: :request do
  let!(:user) { create_human_resource }

  it "describes the login endpoint" do
    get "/api/v1/users/sign_in"

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to include(
      "message" => "Login endpoint",
      "instructions" => "Send POST request with email and password"
    )
  end

  it "authenticates valid credentials" do
    post "/api/v1/users/sign_in", params: { user: { email: user.email, password: "Password123!" } }

    expect(response).to have_http_status(:ok)
    token = JSON.parse(response.body).dig("data", "token")
    expect(token).to be_present
  end

  it "signs out and blacklists the supplied JWT" do
    token, = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)

    expect {
      delete "/api/v1/users/sign_out", headers: { "Authorization" => "Bearer #{token}" }
    }.to change(JwtBlacklist, :count).by(1)
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to include("message" => "Signed out successfully.")
  end
end
