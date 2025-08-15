FactoryBot.define do
  factory :contractor do
    name { Faker::Company.name }
    contact_email { Faker::Internet.email }
  end
end