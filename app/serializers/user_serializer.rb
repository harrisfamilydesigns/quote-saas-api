class UserSerializer < BaseSerializer
  attributes :id, :contractor_id, :supplier_id,
    :email, :role,
    :created_at, :updated_at
end
