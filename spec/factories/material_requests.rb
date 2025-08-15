FactoryBot.define do
  factory :material_request do
    description { Faker::Commerce.product_name + ' material' }
    quantity { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    unit { MaterialRequest::COMMON_UNITS.sample }
    association :project
    
    trait :with_suppliers do
      transient do
        suppliers_count { 2 }
      end
      
      after(:create) do |material_request, evaluator|
        create_list(:material_request_supplier, evaluator.suppliers_count, material_request: material_request)
      end
    end
  end
end