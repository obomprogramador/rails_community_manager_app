class MessageReactionsChannel < ApplicationCable::Channel
  def subscribed
    message_id = params[:message_id]
    stream_from "message_reactions_#{message_id}"
  end

  def unsubscribed
    stop_all_streams
  end
end