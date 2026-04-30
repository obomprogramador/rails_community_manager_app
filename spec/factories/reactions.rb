FactoryBot.define do
  factory :reaction do
    association :message
    association :user
    reaction_type { %w[like love insightful].sample }
  end
end