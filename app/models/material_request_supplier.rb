class MaterialRequestSupplier < ApplicationRecord
  belongs_to :material_request
  belongs_to :supplier

  validates :material_request_id, uniqueness: { scope: :supplier_id }
end
