class UserSerializer
  include Alba::Resource
  
  attributes :id, :email, :role, :created_at
  
  attribute :contractor_id do |user|
    user.contractor_id
  end
  
  attribute :supplier_id do |user|
    user.supplier_id
  end
end