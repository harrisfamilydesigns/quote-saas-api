class MaterialRequest < ApplicationRecord
  belongs_to :project
  has_many :quotes, dependent: :destroy

  # Association for invited suppliers
  has_many :material_request_suppliers, dependent: :destroy
  has_many :invited_suppliers, through: :material_request_suppliers, source: :supplier

  validates :description, presence: true

  scope :with_supplier_invites, ->(supplier_id) {
    joins(:material_request_suppliers).where(material_request_suppliers: { supplier_id: supplier_id })
  }

  # Define some common units
  COMMON_UNITS = %w[piece each ft sqft sheet yard ton lb kg].freeze
end
