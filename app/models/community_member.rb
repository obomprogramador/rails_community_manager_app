class CommunityMember < ApplicationRecord
  belongs_to :community
  belongs_to :user

  validates :role, inclusion: {
    in: CleanArch::Domains::CommunityMemberDomain::ValueObjects::MemberRole::ROLES
  }
end