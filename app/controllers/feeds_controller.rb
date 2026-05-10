class FeedsController < ApplicationController
  MessageDomain         = CleanArch::Domains::MessageDomain
  CommunityDomain       = CleanArch::Domains::CommunityDomain
  CommunityMemberDomain = CleanArch::Domains::CommunityMemberDomain

  def index
    return redirect_to new_session_path, alert: "Faça login para continuar." if session[:user_id].blank?

    memberships = use_case(
      CommunityMemberDomain::UseCases::ListUserMemberships,
      community_member_repository: CommunityMember
    ).call(user_id: session[:user_id])

    community_ids = memberships.map(&:community_id)

    @communities = use_case(
      CommunityDomain::UseCases::ListCommunities,
      community_repository: Community
    ).list_by_ids(ids: community_ids)

    @messages = use_case(
      MessageDomain::UseCases::ListFeedMessages,
      message_repository: Message
    ).call(community_ids: community_ids, limit: 50)
  end
end