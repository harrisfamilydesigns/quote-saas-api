FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password' }

    trait :contractor_user do
      role { 'contractor' }
      association :contractor
    end

    trait :supplier_user do
      role { 'supplier' }
      association :supplier
    end

    trait :admin_user do
      role { 'admin' }
    end

    factory :contractor_user, traits: [ :contractor_user ]
    factory :supplier_user, traits: [ :supplier_user ]
    factory :admin_user, traits: [ :admin_user ]
  end
end
