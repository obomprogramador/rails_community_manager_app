class Reaction < ApplicationRecord
  belongs_to :message
  belongs_to :user

  validates :reaction_type, inclusion: { in: %w[like love insightful] }
end