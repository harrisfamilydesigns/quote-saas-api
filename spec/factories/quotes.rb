FactoryBot.define do
  factory :quote do
    price { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    lead_time_days { Faker::Number.between(from: 1, to: 30) }
    status { 'pending' }
    association :material_request
    association :supplier
    
    trait :accepted do
      status { 'accepted' }
    end
    
    trait :rejected do
      status { 'rejected' }
    end
    
    factory :accepted_quote, traits: [:accepted]
    factory :rejected_quote, traits: [:rejected]
  end
end