class ContractorSerializer
  include Alba::Resource

  root_key :contractor
  root_key_for_collection :contractors

  attributes :id, :name, :contact_email, :created_at, :updated_at
end
