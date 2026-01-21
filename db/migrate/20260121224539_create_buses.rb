class CreateBuses < ActiveRecord::Migration[8.0]
  def change
    create_table :buses do |t|
      t.string :name
      t.string :bus_type
      t.string :plate_number
      t.jsonb :seat_layout
      t.integer :total_seats
      t.boolean :active

      t.timestamps
    end
  end
end
