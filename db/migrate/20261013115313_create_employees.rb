class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :employee_id, null: false
      t.string :job_title, null: false
      t.date :hire_date, null: false
      t.references :department, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.boolean :is_active, default: true

      t.timestamps
    end

    add_index :employees, :email, unique: true
    add_index :employees, :employee_id, unique: true
  end
end
