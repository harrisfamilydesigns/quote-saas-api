FactoryBot.define do
  factory :material_request_supplier do
    association :material_request
    association :supplier
  end
end
