require "test_helper"

class UserTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  test "new users default to the employee role and cannot authenticate" do
    user = User.new

    assert user.employee?
    assert_not user.active_for_authentication?
  end

  test "human resource users can authenticate" do
    user = User.new(role: :human_resource)

    assert user.human_resource?
    assert user.active_for_authentication?
  end
end
