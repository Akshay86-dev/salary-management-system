class CreateLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.string :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country, default: 'USA'
      t.float :latitude
      t.float :longitude

      t.timestamps
    end

    add_index :locations, :name
    add_index :locations, [:city, :state]
  end
end
