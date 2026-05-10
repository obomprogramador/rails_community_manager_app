class FeedsController < ApplicationController
  MessageDomain         = CleanArch::Domains::MessageDomain
  CommunityDomain       = CleanArch::Domains::CommunityDomain
  CommunityMemberDomain = CleanArch::Domains::CommunityMemberDomain

  def index
    return redirect_to new_session_path, alert: "Faça login para continuar." if session[:user_id].blank?

    memberships = CommunityMemberDomain::UseCases::ListUserMemberships.new(
      community_member_repository: CommunityMemberDomain::Repositories::CommunityMemberRepository.new
    ).call(user_id: session[:user_id])

    community_ids = memberships.map(&:community_id)

    @communities = CommunityDomain::UseCases::ListCommunities.new(
      community_repository: CommunityDomain::Repositories::CommunityRepository.new
    ).list_by_ids(ids: community_ids)

    @messages = MessageDomain::UseCases::ListFeedMessages.new(
      message_repository: MessageDomain::Repositories::MessageRepository.new
    ).call(community_ids: community_ids, limit: 50)
  end
end