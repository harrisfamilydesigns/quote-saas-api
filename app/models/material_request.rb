class MaterialRequest < ApplicationRecord
  belongs_to :project
  has_many :quotes, dependent: :destroy
  
  # Association for invited suppliers
  has_many :material_request_suppliers, dependent: :destroy
  has_many :invited_suppliers, through: :material_request_suppliers, source: :supplier
  
  validates :description, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit, presence: true
  
  # Define some common units
  COMMON_UNITS = %w[piece each ft sqft sheet yard ton lb kg].freeze
end
