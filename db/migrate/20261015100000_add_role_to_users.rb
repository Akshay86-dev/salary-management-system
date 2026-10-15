# frozen_string_literal: true

class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :role, :string, null: false, default: "EMPLOYEE"

    # Existing user records are existing login accounts; retain their access.
    execute "UPDATE users SET role = 'HUMAN_RESOURCE'"

    add_check_constraint :users,
                         "role IN ('EMPLOYEE', 'HUMAN_RESOURCE')",
                         name: "users_role_allowed_values"
  end

  def down
    remove_check_constraint :users, name: "users_role_allowed_values"
    remove_column :users, :role
  end
end
