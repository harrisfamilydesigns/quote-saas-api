class ProjectSerializer
  include Alba::Resource
  
  attributes :id, :name, :description, :status, :created_at, :updated_at
  
  attribute :contractor do |project|
    ContractorSerializer.new(project.contractor).serialize
  end
  
  # We'll manually include material_requests in the controller when needed
end