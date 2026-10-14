class AddEmployeeToDepartments < ActiveRecord::Migration[8.1]
  def up
    # Remove the old foreign key constraint (manager_id -> departments)
    remove_foreign_key :departments, :departments
    
    # Change the column type if needed (biginteger for consistency with employees.id)
    # Add the new foreign key constraint (manager_id -> employees)
    add_foreign_key :departments, :employees, column: :manager_id
  end

  def down
    # Remove the employee foreign key
    remove_foreign_key :departments, :employees
    
    # Add back the department self-reference
    add_foreign_key :departments, :departments, column: :manager_id
  end
end
