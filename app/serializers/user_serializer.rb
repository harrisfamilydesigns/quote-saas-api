class UserSerializer
  include Alba::Resource

  root_key :user
  root_key_for_collection :users

  attributes :id, :email, :role, :created_at

  attribute :contractor_id do |user|
    user.contractor_id
  end

  attribute :supplier_id do |user|
    user.supplier_id
  end

  attribute :token do |user|
    # Return the JWT token if it was set by the controller
    user.instance_variable_get(:@auth_token)
  end
end
