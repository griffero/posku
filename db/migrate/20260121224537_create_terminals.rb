class CreateTerminals < ActiveRecord::Migration[8.0]
  def change
    create_table :terminals do |t|
      t.string :name
      t.string :city
      t.string :code
      t.decimal :latitude
      t.decimal :longitude
      t.boolean :active

      t.timestamps
    end
    add_index :terminals, :code, unique: true
  end
end
