class CreatePassengers < ActiveRecord::Migration[8.0]
  def change
    create_table :passengers do |t|
      t.references :reservation, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :document_type
      t.string :document_number
      t.string :seat_number

      t.timestamps
    end
  end
end
