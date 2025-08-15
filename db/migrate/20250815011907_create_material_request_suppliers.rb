class CreateMaterialRequestSuppliers < ActiveRecord::Migration[8.0]
  def change
    create_table :material_request_suppliers do |t|
      t.references :material_request, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true

      t.timestamps
    end
    
    # Add a unique index to prevent duplicates
    add_index :material_request_suppliers, [:material_request_id, :supplier_id], unique: true, name: 'index_material_req_suppliers_on_material_req_id_and_supplier_id'
  end
end
