FactoryBot.define do
  factory :project do
    name { Faker::Company.name + ' Project' }
    description { Faker::Lorem.paragraph }
    status { 'draft' }
    association :contractor
    
    trait :open do
      status { 'open' }
    end
    
    trait :closed do
      status { 'closed' }
    end
    
    factory :open_project, traits: [:open]
    factory :closed_project, traits: [:closed]
  end
end