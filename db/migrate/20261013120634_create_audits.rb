class CreateAudits < ActiveRecord::Migration[8.1]
  def change
    create_table :audits do |t|
      t.references :user, null: true, foreign_key: true
      t.integer :action, null: false
      t.integer :auditable_type, null: false
      t.integer :auditable_id, null: false
      t.jsonb :previous_data, default: {}
      t.jsonb :new_data, default: {}
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :audits, [:auditable_type, :auditable_id], name: 'index_audits_on_auditable'
    add_index :audits, :auditable_type
    add_index :audits :action
    add_index :audits, [:user_id, :auditable_type]
  end
end
