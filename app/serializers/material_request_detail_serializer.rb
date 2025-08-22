class MaterialRequestDetailSerializer < MaterialRequestSerializer
  one :project, serializer: ProjectSerializer
  many :invited_suppliers, serializer: SupplierSerializer

  attribute :quote_count do |material_request|
    material_request.quotes.count
  end
end
