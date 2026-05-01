class FeedsController < ApplicationController
    def index
      return redirect_to new_session_path, alert: "Faça login para continuar." if session[:user_id].blank?
  
      community_ids = CommunityMember.where(user_id: session[:user_id]).select(:community_id)
  
      @communities = Community
        .joins(:community_members)
        .where(community_members: { user_id: session[:user_id] })
        .distinct
        .order(:name)
  
      @messages = Message
        .includes(:user, :community)
        .where(parent_message_id: nil, community_id: community_ids)
        .order(created_at: :desc)
        .limit(50)
    end
  end