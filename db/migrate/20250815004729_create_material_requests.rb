class CreateMaterialRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :material_requests do |t|
      t.references :project, null: false, foreign_key: true
      t.text :description
      t.decimal :quantity
      t.string :unit

      t.timestamps
    end
  end
end
