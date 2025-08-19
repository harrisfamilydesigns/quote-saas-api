class ProjectSerializer
  include Alba::Resource

  root_key :project
  root_key_for_collection :projects

  attributes :id, :name, :description, :status, :created_at, :updated_at

  attribute :contractor do |project|
    ContractorSerializer.new(project.contractor).serialize
  end

  attribute :material_request_count do |project|
    MaterialRequestSerializer.new(project.material_requests).serialize
  end
end
