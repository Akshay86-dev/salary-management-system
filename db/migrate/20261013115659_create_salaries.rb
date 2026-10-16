class CreateSalaries < ActiveRecord::Migration[8.1]
  def change
    create_table :salaries do |t|
      t.references :employee, null: false, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :currency, null: false, default: 'USD'
      t.integer :salary_type, null: false, default: 0
      t.date :effective_date, null: false
      t.boolean :is_current, default: true

      t.timestamps
    end

    add_index :salaries, [ :employee_id, :is_current ]
    add_index :salaries, [ :employee_id, :salary_type, :is_current ], where: "is_current = true", name: 'index_salaries_on_current_by_type'
  end
end
