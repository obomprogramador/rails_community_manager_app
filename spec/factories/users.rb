FactoryBot.define do
  factory :user, class: 'User' do
    username { Faker::Internet.unique.username(specifier: 5..20, separators: ['_']) }
    active   { true }

    trait :with_username do
      username { 'john_doe' }
    end

    trait :inactive do
      active { false }
    end
  end
end