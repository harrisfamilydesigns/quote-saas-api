class Supplier < ApplicationRecord
  has_many :users
  has_many :quotes, dependent: :destroy
  
  # Association for material requests this supplier is invited to
  has_many :material_request_suppliers, dependent: :destroy
  has_many :invited_material_requests, through: :material_request_suppliers, source: :material_request
  
  validates :name, presence: true
  validates :contact_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
