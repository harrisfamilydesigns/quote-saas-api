class QuoteSerializer
  include Alba::Resource

  root_key :quote
  root_key_for_collection :quotes

  attributes :id, :supplier_id, :material_request_id, :price, :lead_time_days, :status, :created_at, :updated_at

  attribute :project_id do |quote|
    quote.material_request.project_id
  end

  attribute :project do |quote|
    ProjectSerializer.new(quote.material_request.project).serialize
  end

  attribute :material_request do |quote|
    MaterialRequestSerializer.new(quote.material_request).serialize
  end

  attribute :supplier do |quote|
    SupplierSerializer.new(quote.supplier).serialize
  end
end
