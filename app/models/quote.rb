class Quote < ApplicationRecord
  belongs_to :material_request
  belongs_to :supplier
  
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :lead_time_days, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true
  
  # Define valid statuses
  STATUSES = %w[pending accepted rejected].freeze
  validates :status, inclusion: { in: STATUSES }
  
  # Set default status to pending
  after_initialize :set_default_status, if: :new_record?
  
  private
  
  def set_default_status
    self.status ||= 'pending'
  end
end
