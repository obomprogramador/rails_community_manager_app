FactoryBot.define do
  factory :community_member do
    association :community
    association :user
    role { 'member' }
  end
end