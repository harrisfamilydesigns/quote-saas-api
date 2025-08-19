class MaterialRequestSerializer
  include Alba::Resource

  root_key :material_request
  root_key_for_collection :material_requests

  attributes :id, :project_id, :description, :quantity, :unit, :created_at, :updated_at
end
