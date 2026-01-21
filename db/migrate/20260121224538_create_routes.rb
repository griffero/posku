class CreateRoutes < ActiveRecord::Migration[8.0]
  def change
    create_table :routes do |t|
      t.references :origin_terminal, null: false, foreign_key: { to_table: :terminals }
      t.references :destination_terminal, null: false, foreign_key: { to_table: :terminals }
      t.integer :distance_km
      t.integer :duration_minutes
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :routes, [:origin_terminal_id, :destination_terminal_id], unique: true
  end
end
