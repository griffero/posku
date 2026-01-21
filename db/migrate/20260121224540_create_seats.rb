class CreateSeats < ActiveRecord::Migration[8.0]
  def change
    create_table :seats do |t|
      t.references :bus, null: false, foreign_key: true
      t.string :seat_number
      t.string :seat_class
      t.integer :floor
      t.integer :row_number
      t.integer :column_number

      t.timestamps
    end
  end
end
