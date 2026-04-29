class MessagesController < ApplicationController
  MessageDomain = CleanArch::Domains::MessageDomain

  def index
    output = MessageDomain::UseCases::ListCommunityMessages.new(
      message_repository: MessageDomain::Repositories::MessageRepository.new
    ).call(community_id: params[:community_id])

    render json: output.map(&:to_h), status: :ok
  rescue CleanArch::Domains::DomainError => e
    render json: { error: e.message }, status: :unprocessable_entity
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

    render json: output.to_h, status: :created
  rescue CleanArch::Domains::DomainError, ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
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

    render json: output.to_h, status: :created
  rescue CleanArch::Domains::DomainError, ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def replies
    output = MessageDomain::UseCases::ListMessageReplies.new(
      message_repository: MessageDomain::Repositories::MessageRepository.new
    ).call(message_id: params[:id])

    render json: output.map(&:to_h), status: :ok
  rescue CleanArch::Domains::DomainError => e
    render json: { error: e.message }, status: :unprocessable_entity
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