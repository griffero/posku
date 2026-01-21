class CreateTrips < ActiveRecord::Migration[8.0]
  def change
    create_table :trips do |t|
      t.references :route, null: false, foreign_key: true
      t.references :bus, null: false, foreign_key: true
      t.datetime :departure_at, null: false
      t.datetime :arrival_at, null: false
      t.string :status, null: false, default: "scheduled"

      t.timestamps
    end

    add_index :trips, :departure_at
    add_index :trips, :status
    add_index :trips, [:route_id, :departure_at]
  end
end
