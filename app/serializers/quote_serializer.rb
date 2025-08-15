class QuoteSerializer
  include Alba::Resource

  root_key :quote
  root_key_for_collection :quotes

  attributes :id, :price, :lead_time_days, :status, :created_at, :updated_at

  attribute :material_request_id do |quote|
    quote.material_request_id
  end

  attribute :supplier do |quote|
    SupplierSerializer.new(quote.supplier).serialize
  end
end
