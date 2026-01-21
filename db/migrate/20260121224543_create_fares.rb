class CreateFares < ActiveRecord::Migration[8.0]
  def change
    create_table :fares do |t|
      t.references :trip, null: false, foreign_key: true
      t.string :seat_class
      t.string :currency
      t.integer :base_price_cents
      t.jsonb :pricing_rules

      t.timestamps
    end
  end
end
