class MaterialRequestSerializer
  include Alba::Resource
  
  attributes :id, :description, :quantity, :unit, :created_at, :updated_at
  
  attribute :project_id do |material_request|
    material_request.project_id
  end
  
  # We'll manually include quotes and invited_suppliers in the controller when needed
end