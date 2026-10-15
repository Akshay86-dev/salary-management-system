# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Locations API", type: :request do
  let(:headers) { auth_headers }

  it "lists, filters, and shows locations" do
    california = create_location(name: "West Office", state: "CA")
    create_location(name: "Toronto Office", state: "ON", country: "Canada")

    get "/api/v1/locations", headers: headers
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).dig("data").size).to eq(2)

    get "/api/v1/locations", params: { state: "CA", query: "west" }, headers: headers
    expect(JSON.parse(response.body).dig("data").map { |item| item.fetch("id") })
      .to eq([ california.id.to_s ])

    get "/api/v1/locations/#{california.id}", headers: headers
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).dig("data", "attributes", "country")).to eq("USA")
  end

  it "creates locations and returns validation errors" do
    expect {
      post "/api/v1/locations",
           params: json_attributes(name: "New Office", city: "Toronto", country: "Canada"), headers: headers
    }.to change(Location, :count).by(1)
    expect(response).to have_http_status(:created)

    post "/api/v1/locations", params: json_attributes(name: "Unknown", country: "Atlantis"), headers: headers
    expect(response).to have_http_status(:unprocessable_content)
    expect(JSON.parse(response.body)).to have_key("errors")
  end

  it "updates and deletes locations" do
    location = create_location

    patch "/api/v1/locations/#{location.id}", params: json_attributes(city: "San Francisco"), headers: headers
    expect(response).to have_http_status(:ok)
    expect(location.reload.city).to eq("San Francisco")

    put "/api/v1/locations/#{location.id}", params: json_attributes(state: "NY"), headers: headers
    expect(response).to have_http_status(:ok)
    expect(location.reload.state).to eq("NY")

    expect {
      delete "/api/v1/locations/#{location.id}", headers: headers
    }.to change(Location, :count).by(-1)
    expect(response).to have_http_status(:no_content)
  end
end
