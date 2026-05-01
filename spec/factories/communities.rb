FactoryBot.define do
  factory :community do
    association :creator, factory: :user
    name        { Faker::Company.unique.name }
    description { Faker::Lorem.sentence }
  end
end