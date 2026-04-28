class User < ApplicationRecord
  has_many :community_members
  has_many :communities, through: :community_members
  has_many :messages
  has_many :reactions
end