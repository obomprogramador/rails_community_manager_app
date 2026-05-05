module Api
  module V1
    class MessagesController < BaseController
      MessageDomain = CleanArch::Domains::MessageDomain
      UserDomain    = CleanArch::Domains::UserDomain

      def index
        page     = [params.fetch(:page, 1).to_i, 1].max
        per_page = [params.fetch(:per_page, 50).to_i, 1].max

        use_case = MessageDomain::UseCases::ListCommunityMessages.new(
          message_repository: MessageDomain::Repositories::MessageRepository.new
        )

        output = if params[:page].present? || params[:per_page].present?
          use_case.call_paginated(
            community_id: params[:community_id],
            page:         page,
            per_page:     per_page
          )
        else
          use_case.call(community_id: params[:community_id])
        end

        render json: output.map(&:to_h), status: :ok
      rescue CleanArch::Domains::DomainError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def top
        limit = params.fetch(:limit, 10).to_i

        use_case = MessageDomain::UseCases::ListTopMessages.new(
          message_repository: MessageDomain::Repositories::MessageRepository.new
        )

        output = use_case.call(
          community_id: params[:id],
          limit: limit
        )

        render json: {
          messages: output.map do |msg|
            {
              id: msg.id,
              content: msg.content,
              user: {
                id: msg.user_id,
                username: msg.username
              },
              ai_sentiment_score: msg.sentiment_score,
              reactions_count: msg.reactions_count,
              replies_count: msg.replies_count,
              engagement_score: msg.engagement_score
            }
          end
        }, status: :ok
      rescue CleanArch::Domains::DomainError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def create
        input_dto = MessageDomain::Dtos::CreateMessageInputDto.new(
          username:          params.require(:username),
          community_id:      params.require(:community_id),
          content:           params.require(:content),
          user_ip:           params[:user_ip].presence || request.remote_ip,
          parent_message_id: params[:parent_message_id]
        )

        output = MessageDomain::UseCases::CreateMessage.new(
          message_repository: MessageDomain::Repositories::MessageRepository.new,
          user_repository:    UserDomain::Repositories::UserRepository.new
        ).call(input_dto)

        render json: output.to_h, status: :created
      rescue ActionController::ParameterMissing => e
        render json: { error: "Parâmetro obrigatório ausente: #{e.param}" }, status: :bad_request
      rescue ArgumentError => e
        render json: { error: e.message }, status: :bad_request
      rescue CleanArch::Domains::DomainError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end