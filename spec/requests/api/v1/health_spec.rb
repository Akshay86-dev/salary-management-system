# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Health endpoints", type: :request do
  it "returns API health without requiring authentication" do
    get "/api/v1/health"

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to include(
      "status" => "ok",
      "database" => "connected",
      "version" => "1.0.0"
    )
  end

  it "returns the Rails health response" do
    get "/up"

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq("status" => "ok")
  end
end
