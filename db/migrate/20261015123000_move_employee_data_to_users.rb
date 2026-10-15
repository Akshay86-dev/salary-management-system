# frozen_string_literal: true

class MoveEmployeeDataToUsers < ActiveRecord::Migration[8.1]
  def up
    ensure_unambiguous_emails!

    add_column :users, :employee_id, :string
    add_column :users, :job_title, :string
    add_column :users, :hire_date, :date
    add_column :users, :department_id, :bigint
    add_column :users, :location_id, :bigint
    add_column :users, :is_active, :boolean, null: false, default: true

    execute <<~SQL
      UPDATE users
      SET email = lower(btrim(email))
    SQL

    execute <<~SQL
      UPDATE users AS users
      SET first_name = employees.first_name,
          last_name = employees.last_name,
          employee_id = employees.employee_id,
          job_title = employees.job_title,
          hire_date = employees.hire_date,
          department_id = employees.department_id,
          location_id = employees.location_id,
          is_active = COALESCE(employees.is_active, TRUE)
      FROM employees
      WHERE lower(btrim(users.email)) = lower(btrim(employees.email))
    SQL

    execute <<~SQL
      INSERT INTO users (
        email, encrypted_password, first_name, last_name, role,
        employee_id, job_title, hire_date, department_id, location_id,
        is_active, created_at, updated_at
      )
      SELECT lower(btrim(employees.email)), '', employees.first_name, employees.last_name,
             'EMPLOYEE', employees.employee_id, employees.job_title, employees.hire_date,
             employees.department_id, employees.location_id, COALESCE(employees.is_active, TRUE),
             employees.created_at, employees.updated_at
      FROM employees
      WHERE NOT EXISTS (
        SELECT 1
        FROM users
        WHERE lower(btrim(users.email)) = lower(btrim(employees.email))
      )
    SQL

    remove_foreign_key :departments, column: :manager_id
    remove_foreign_key :salaries, :employees

    create_mapping_table
    remap_references

    remove_index :users, name: "index_users_on_email"
    add_index :users, "lower(email)", unique: true, name: "index_users_on_lower_email"
    add_index :users, :employee_id, unique: true, where: "employee_id IS NOT NULL"
    add_index :users, :department_id
    add_index :users, :location_id

    drop_table :employees

    add_foreign_key :users, :departments
    add_foreign_key :users, :locations
    add_foreign_key :departments, :users, column: :manager_id
    add_foreign_key :salaries, :users, column: :employee_id

    add_check_constraint :users,
                         "role <> 'EMPLOYEE' OR (employee_id IS NOT NULL AND job_title IS NOT NULL AND hire_date IS NOT NULL AND department_id IS NOT NULL AND location_id IS NOT NULL)",
                         name: "users_employee_details_required"
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "Employee and user records have been merged and cannot be safely separated automatically."
  end

  private

  def ensure_unambiguous_emails!
    duplicate_user_email = select_value(<<~SQL)
      SELECT lower(btrim(email))
      FROM users
      GROUP BY lower(btrim(email))
      HAVING count(*) > 1 OR lower(btrim(email)) = ''
      LIMIT 1
    SQL
    duplicate_employee_email = select_value(<<~SQL)
      SELECT lower(btrim(email))
      FROM employees
      GROUP BY lower(btrim(email))
      HAVING count(*) > 1 OR lower(btrim(email)) = ''
      LIMIT 1
    SQL
    employee_user_without_profile = select_value(<<~SQL)
      SELECT users.id
      FROM users
      WHERE users.role = 'EMPLOYEE'
        AND NOT EXISTS (
          SELECT 1
          FROM employees
          WHERE lower(btrim(employees.email)) = lower(btrim(users.email))
        )
      LIMIT 1
    SQL

    return if duplicate_user_email.nil? && duplicate_employee_email.nil? && employee_user_without_profile.nil?

    raise ActiveRecord::MigrationError,
          "Cannot merge employees into users: resolve duplicate emails and employee users without a matching employee record."
  end

  def create_mapping_table
    execute <<~SQL
      CREATE TEMPORARY TABLE employee_user_id_map (
        employee_id bigint PRIMARY KEY,
        user_id bigint NOT NULL
      ) ON COMMIT DROP
    SQL

    execute <<~SQL
      INSERT INTO employee_user_id_map (employee_id, user_id)
      SELECT employees.id, users.id
      FROM employees
      INNER JOIN users ON lower(btrim(users.email)) = lower(btrim(employees.email))
    SQL
  end

  def remap_references
    execute <<~SQL
      UPDATE salaries
      SET employee_id = employee_user_id_map.user_id
      FROM employee_user_id_map
      WHERE salaries.employee_id = employee_user_id_map.employee_id
    SQL

    execute <<~SQL
      UPDATE departments
      SET manager_id = employee_user_id_map.user_id
      FROM employee_user_id_map
      WHERE departments.manager_id = employee_user_id_map.employee_id
    SQL

    execute <<~SQL
      UPDATE versions
      SET item_type = 'User',
          item_id = employee_user_id_map.user_id
      FROM employee_user_id_map
      WHERE versions.item_type = 'Employee'
        AND versions.item_id = employee_user_id_map.employee_id
    SQL
  end
end
