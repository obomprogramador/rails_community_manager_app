module Api
  module V1
    class ReactionsController < BaseController
      ReactionDomain = CleanArch::Domains::ReactionDomain

      def create
        input_dto = ReactionDomain::Dtos::AddReactionInputDto.new(
          message_id:    params.require(:message_id),
          user_id:       params.require(:user_id),
          reaction_type: params.require(:reaction_type)
        )

        output = ReactionDomain::UseCases::AddReaction.new(
          reaction_repository: ReactionDomain::Repositories::ReactionRepository.new
        ).call_api_v1(input_dto)

        render json: output.to_h, status: :ok
      rescue ActionController::ParameterMissing => e
        render json: { error: "Parâmetro obrigatório ausente: #{e.param}" }, status: :bad_request
      rescue CleanArch::Domains::DomainError => e
        render json: { error: e.message }, status: :conflict
      end
    end
  end
end