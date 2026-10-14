class CreateDepartments < ActiveRecord::Migration[8.1]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.decimal :budget, precision: 12, scale: 2
      t.bigint :manager_id  # References employees table

      t.timestamps
    end

    add_index :departments, :name, unique: true
    add_foreign_key :departments, :employees, column: :manager_id
  end
end
