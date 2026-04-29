FactoryBot.define do
  factory :community do
    name        { Faker::Company.unique.name }
    description { Faker::Lorem.sentence }
  end
end