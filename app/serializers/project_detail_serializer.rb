class ProjectDetailSerializer < ProjectSerializer
  has_many :material_requests, serializer: MaterialRequestDetailSerializer
end
