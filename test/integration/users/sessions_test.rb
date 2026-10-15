require "test_helper"

class Users::SessionsTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []

  test "signing out returns a JSON success response" do
    delete "/api/v1/users/sign_out"

    assert_response :ok
    assert_equal({ "message" => "Signed out successfully." }, response.parsed_body)
  end
end
