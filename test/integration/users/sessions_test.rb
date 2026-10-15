require "test_helper"

class Users::SessionsTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []

  test "signing out returns a JSON success response" do
    delete "/api/v1/users/sign_out"

    assert_response :ok
    assert_equal({ "message" => "Signed out successfully." }, response.parsed_body)
  end

  test "employee users cannot sign in" do
    suffix = SecureRandom.hex(4)
    department = Department.create!(name: "Employee Sign In #{suffix}")
    location = Location.create!(name: "Employee Sign In #{suffix}", country: "USA")
    user = User.create!(
      email: "employee@example.com",
      first_name: "Regular",
      last_name: "Employee",
      employee_id: "EMP-#{SecureRandom.random_number(100_000).to_s.rjust(5, '0')}",
      job_title: "Staff",
      hire_date: Date.current,
      department: department,
      location: location
    )

    assert user.employee?
    post "/api/v1/users/sign_in",
         params: { user: { email: user.email, password: "password123" } },
         as: :json

    assert_response :unauthorized
    assert_nil response.parsed_body.dig("data", "token")
  end

  test "human resource users can sign in" do
    user = User.create!(
      email: "hr@example.com",
      password: "password123",
      first_name: "Human",
      last_name: "Resources",
      role: :human_resource
    )

    post "/api/v1/users/sign_in",
         params: { user: { email: user.email, password: "password123" } },
         as: :json

    assert_response :ok
    assert_equal "HUMAN_RESOURCE", response.parsed_body.dig("data", "attributes", "role")
    assert response.parsed_body.dig("data", "token").present?
  end

  test "profile returns the signed-in user's attributes" do
    user = User.create!(
      email: "profile-hr@example.com",
      password: "password123",
      first_name: "Human",
      last_name: "Resources",
      role: :human_resource
    )

    post "/api/v1/users/sign_in",
         params: { user: { email: user.email, password: "password123" } },
         as: :json
    token = response.parsed_body.dig("data", "token")

    get "/api/v1/auth/profile",
        headers: { "Authorization" => "Bearer #{token}" },
        as: :json

    assert_response :ok
    assert_equal(
      {
        "email" => user.email,
        "first_name" => user.first_name,
        "last_name" => user.last_name,
        "full_name" => user.full_name,
        "role" => "HUMAN_RESOURCE"
      },
      response.parsed_body.dig("data", "attributes")
    )
  end
end
