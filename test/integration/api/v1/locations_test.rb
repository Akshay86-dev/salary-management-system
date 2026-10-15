require "test_helper"

class Api::V1::LocationsTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []

  setup do
    user = User.create!(
      email: "locations-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      first_name: "Location",
      last_name: "Test",
      role: :human_resource
    )

    post "/api/v1/users/sign_in",
         params: { user: { email: user.email, password: "password123" } },
         as: :json
    @authorization_headers = {
      "Authorization" => "Bearer #{response.parsed_body.dig("data", "token")}"
    }
  end

  test "index filters locations by state and query" do
    california_location = Location.create!(
      name: "North Office",
      state: "CA",
      country: "USA"
    )
    new_york_location = Location.create!(
      name: "South Office",
      state: "NY",
      country: "USA"
    )

    get "/api/v1/locations",
        params: { state: "CA" },
        headers: @authorization_headers,
        as: :json

    assert_response :ok
    assert_equal [ california_location.id.to_s ], response.parsed_body.fetch("data").map { |location| location.fetch("id") }

    get "/api/v1/locations",
        params: { query: "south" },
        headers: @authorization_headers,
        as: :json

    assert_response :ok
    assert_equal [ new_york_location.id.to_s ], response.parsed_body.fetch("data").map { |location| location.fetch("id") }
  end
end
