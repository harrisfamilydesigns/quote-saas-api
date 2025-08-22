class QuoteDetailSerializer < QuoteSerializer
  one :material_request, serializer: MaterialRequestDetailSerializer
  one :supplier, serializer: SupplierSerializer

  attribute :project do |quote|
    ProjectSerializer.new(quote.material_request.project).serializable_hash
  end
end
