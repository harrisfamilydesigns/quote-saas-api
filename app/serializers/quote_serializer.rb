class QuoteSerializer < BaseSerializer
  attributes :id, :supplier_id, :material_request_id, :price, :lead_time_days, :status, :created_at, :updated_at

  attribute :project_id do |quote|
    quote.material_request.project_id
  end
end
