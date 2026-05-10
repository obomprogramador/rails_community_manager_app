class CommunityMember < ApplicationRecord
  belongs_to :community
  belongs_to :user

  validates :role, inclusion: {
    in: CleanArch::Domains::CommunityMemberDomain::ValueObjects::MemberRole::ROLES
  }

  def self.list_by_user(user_id)
    where(user_id: user_id).order(:created_at)
  end
end