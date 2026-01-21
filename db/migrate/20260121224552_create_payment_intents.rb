class CreatePaymentIntents < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_intents do |t|
      t.references :reservation, null: false, foreign_key: true
      t.string :provider
      t.string :status
      t.integer :amount_cents
      t.string :currency
      t.string :external_id
      t.jsonb :metadata
      t.datetime :expires_at

      t.timestamps
    end
  end
end
