class Community < ApplicationRecord
  belongs_to :creator, class_name: "User"

  has_many :community_members
  has_many :users, through: :community_members
  has_many :messages

  def self.list_by_ids(ids)
    where(id: ids).order(:name)
  end
end