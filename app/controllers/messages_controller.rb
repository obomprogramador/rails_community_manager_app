class MessagesController < ApplicationController
  MessageDomain = CleanArch::Domains::MessageDomain

  def index
    output = MessageDomain::UseCases::ListCommunityMessages.new(
      message_repository: MessageDomain::Repositories::MessageRepository.new
    ).call(community_id: params[:community_id])
  
    @community_id = params[:community_id]
    @messages = output
  
    respond_to do |format|
      format.html # renderiza app/views/messages/index.html.haml
      format.json { render json: output.map(&:to_h), status: :ok }
    end
  rescue CleanArch::Domains::DomainError => e
    respond_to do |format|
      format.html do
        flash.now[:alert] = e.message
        @community_id = params[:community_id]
        @messages = []
        render :index, status: :unprocessable_entity
      end
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end

  def create
    input_dto = MessageDomain::Dtos::PostMessageInputDto.new(
      user_id:      params[:user_id],
      community_id: params[:community_id],
      content:      params[:content],
      user_ip:      request.remote_ip
    )
  
    output = MessageDomain::UseCases::PostMessage.new(
      message_repository: MessageDomain::Repositories::MessageRepository.new
    ).call(input_dto)
  
    ActionCable.server.broadcast(
      "community_messages_#{params[:community_id]}",
      {
        type:    "new_message",
        message: output.to_h
      }
    )
  
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          "messages_list",
          partial: "messages/message",
          locals: { message: output }
        )
      end
  
      format.html do
        redirect_to community_messages_path(params[:community_id]),
                    notice: "Mensagem enviada com sucesso."
      end
  
      format.json { render json: output.to_h, status: :created }
    end
  
  rescue CleanArch::Domains::DomainError, ArgumentError => e
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "message_form_error",
          partial: "shared/error",
          locals: { message: e.message }
        ), status: :unprocessable_entity
      end
  
      format.html do
        redirect_to community_messages_path(params[:community_id]),
                    alert: e.message
      end
  
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end

  def reply
    input_dto = MessageDomain::Dtos::ReplyMessageInputDto.new(
      user_id:           params[:user_id],
      community_id:      params[:community_id],
      parent_message_id: params[:id],
      content:           params[:content],
      user_ip:           request.remote_ip
    )
  
    output = MessageDomain::UseCases::ReplyToMessage.new(
      message_repository: MessageDomain::Repositories::MessageRepository.new
    ).call(input_dto)
  
    thread = MessageDomain::UseCases::ListMessageReplies.new(
      message_repository: MessageDomain::Repositories::MessageRepository.new
    ).call(message_id: params[:id])
  
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "replies_#{params[:id]}",
          partial: "messages/replies",
          locals: {
            community_id: params[:community_id],
            parent_message_id: params[:id],
            replies: thread.replies
          }
        )
      end
      format.html do
        redirect_to replies_community_message_path(
                      params[:community_id],
                      params[:id]
                    ),
                    notice: "Resposta enviada com sucesso."
      end
      format.json { render json: output.to_h, status: :created }
    end
  rescue CleanArch::Domains::DomainError, ArgumentError => e
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "replies_#{params[:id]}",
          partial: "messages/replies",
          locals: {
            community_id: params[:community_id],
            parent_message_id: params[:id],
            replies: []
          }
        ), status: :unprocessable_entity
      end
      format.html do
        redirect_to replies_community_message_path(
                      params[:community_id],
                      params[:id]
                    ),
                    alert: e.message
      end
      format.json {
        render json: { error: e.message },
        status: :unprocessable_entity
      }
    end
  end

  def replies
    thread = MessageDomain::UseCases::ListMessageReplies.new(
      message_repository: MessageDomain::Repositories::MessageRepository.new
    ).call(message_id: params[:id])
  
    respond_to do |format|
      format.html do
        frame_id = "replies_#{params[:id]}"
        if request.headers["Turbo-Frame"] == frame_id
          render partial: "messages/replies",
                 locals: {
                   community_id: params[:community_id],
                   parent_message_id: params[:id],
                   replies: thread.replies
                 }
        else
          @community_id = params[:community_id]
          @parent_message = thread.parent_message
          @replies = thread.replies
          render :replies
        end
      end
      format.json { render json: thread.to_h, status: :ok }
    end
  rescue CleanArch::Domains::DomainError => e
    respond_to do |format|
      format.html { render plain: e.message, status: :unprocessable_entity }
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end

  def destroy
    MessageDomain::UseCases::DeleteMessage.new(
      message_repository: MessageDomain::Repositories::MessageRepository.new
    ).call(
      message_id:          params[:id],
      requesting_user_id:  params[:user_id].to_i
    )

    render json: { message: "Mensagem deletada com sucesso" }, status: :ok
  rescue CleanArch::Domains::DomainError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def analyze_sentiment
    output = MessageDomain::UseCases::AnalyzeMessageSentiment.new(
      message_repository: MessageDomain::Repositories::MessageRepository.new,
      ai_repository:      MessageDomain::Repositories::AiRepository.new
    ).call(message_id: params[:id])

    render json: output.to_h, status: :ok
  rescue CleanArch::Domains::DomainError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end