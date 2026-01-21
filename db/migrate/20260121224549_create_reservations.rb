class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :reservations do |t|
      t.references :trip, null: false, foreign_key: true
      t.string :status
      t.datetime :hold_expires_at
      t.string :locator_code
      t.string :contact_email
      t.string :contact_phone
      t.integer :total_amount_cents
      t.string :currency

      t.timestamps
    end
    add_index :reservations, :locator_code, unique: true
  end
end
