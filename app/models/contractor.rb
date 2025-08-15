class Contractor < ApplicationRecord
  has_many :users
  has_many :projects, dependent: :destroy
  
  validates :name, presence: true
  validates :contact_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
