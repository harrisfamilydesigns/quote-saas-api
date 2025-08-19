class Project < ApplicationRecord
  belongs_to :contractor
  has_many :material_requests, dependent: :destroy

  validates :name, presence: true
  validates :status, presence: true

  # Define valid statuses
  STATUSES = %w[draft open closed].freeze
  validates :status, inclusion: { in: STATUSES }

  # Set default status to draft
  after_initialize :set_default_status, if: :new_record?

  scope :with_material_request_supplier_invites, ->(supplier_id) {
    joins(:material_requests).merge(MaterialRequest.with_supplier_invites(supplier_id))
  }

  private

  def set_default_status
    self.status ||= 'draft'
  end
end
