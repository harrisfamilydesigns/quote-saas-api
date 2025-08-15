class SupplierSerializer
  include Alba::Resource

  root_key :supplier
  root_key_for_collection :suppliers

  attributes :id, :name, :contact_email, :created_at, :updated_at
end
