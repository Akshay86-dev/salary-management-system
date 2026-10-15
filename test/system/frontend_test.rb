# frozen_string_literal: true

require "test_helper"

class FrontendTest < ActionDispatch::SystemTestCase
  self.fixture_table_names = []

  driven_by :selenium, using: :headless_chrome

  test "authenticates an HR user through the React app and serves client-side routes" do
    user = User.create!(
      email: "frontend-hr-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      first_name: "Frontend",
      last_name: "HR",
      role: :human_resource
    )

    visit "/login"
    assert_selector "#root > *"
    assert_title "Salary Management System"
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    assert_current_path "/"
    assert_text "Frontend HR"

    visit "/employees/123/edit"
    assert_selector "#root > *"
  end
end
