class CommunityMember < ApplicationRecord
  belongs_to :community
  belongs_to :user

  validates :role, inclusion: { in: %w[member moderator admin] }
end