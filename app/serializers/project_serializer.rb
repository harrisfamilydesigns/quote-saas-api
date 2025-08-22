class ProjectSerializer < BaseSerializer
  attributes :id, :name, :description, :status, :created_at, :updated_at

  attribute :material_request_count do |project|
    project.material_requests.count
  end

  attribute :quote_count do |project|
    project.material_requests.joins(:quotes).count
  end
end
