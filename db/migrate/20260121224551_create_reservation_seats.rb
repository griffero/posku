class CreateReservationSeats < ActiveRecord::Migration[8.0]
  def change
    create_table :reservation_seats do |t|
      t.references :reservation, null: false, foreign_key: true
      t.string :seat_number
      t.string :seat_class
      t.integer :price_cents
      t.string :status

      t.timestamps
    end
  end
end
