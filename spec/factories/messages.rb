FactoryBot.define do
  factory :message do
    association :user
    association :community
    content           { Faker::Lorem.paragraph }
    user_ip           { Faker::Internet.ip_v4_address }
    parent_message_id { nil }
    ai_sentiment_score { nil }
  end
end