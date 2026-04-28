class Community < ApplicationRecord
  has_many :community_members
  has_many :users, through: :community_members
  has_many :messages
end