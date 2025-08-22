class MaterialRequestSerializer < BaseSerializer
  attributes :id, :project_id, :description, :quantity, :unit, :created_at, :updated_at
end
