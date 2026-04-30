class CommunityMessagesChannel < ApplicationCable::Channel
  def subscribed
    community_id = params[:community_id]
    stream_from "community_messages_#{community_id}"
  end

  def unsubscribed
    stop_all_streams
  end
end