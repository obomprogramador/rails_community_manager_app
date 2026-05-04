FactoryBot.define do
  factory :reaction do
    association :message
    association :user
    reaction_type { %w[like love haha wow sad angry insightful].sample }
  end
end