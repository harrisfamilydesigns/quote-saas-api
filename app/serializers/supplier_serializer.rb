class SupplierSerializer
  include Alba::Resource
  
  attributes :id, :name, :contact_email, :created_at, :updated_at
end