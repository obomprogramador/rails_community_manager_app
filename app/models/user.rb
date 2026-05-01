class User < ApplicationRecord
  has_many :created_communities, class_name: "Community", foreign_key: :creator_id, inverse_of: :creator, dependent: :restrict_with_exception

  has_many :community_members
  has_many :communities, through: :community_members
  has_many :messages
  has_many :reactions
end