class CreateQuotes < ActiveRecord::Migration[8.0]
  def change
    create_table :quotes do |t|
      t.references :material_request, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true
      t.decimal :price
      t.integer :lead_time_days
      t.string :status

      t.timestamps
    end
  end
end
