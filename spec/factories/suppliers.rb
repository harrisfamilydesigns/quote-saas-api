FactoryBot.define do
  factory :supplier do
    name { Faker::Company.name }
    contact_email { Faker::Internet.email }
  end
end