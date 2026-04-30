class ReactionsController < ApplicationController
  ReactionDomain = CleanArch::Domains::ReactionDomain

  def index
    output = ReactionDomain::UseCases::ListMessageReactions.new(
      reaction_repository: ReactionDomain::Repositories::ReactionRepository.new
    ).call(message_id: params[:message_id])

    render json: output.map(&:to_h), status: :ok
  rescue CleanArch::Domains::DomainError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def create
    input_dto = ReactionDomain::Dtos::AddReactionInputDto.new(
      message_id:    params[:message_id],
      user_id:       params[:user_id],
      reaction_type: params[:reaction_type]
    )

    output = ReactionDomain::UseCases::AddReaction.new(
      reaction_repository: ReactionDomain::Repositories::ReactionRepository.new
    ).call(input_dto)

    render json: output.to_h, status: :created
  rescue CleanArch::Domains::DomainError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def destroy
    input_dto = ReactionDomain::Dtos::RemoveReactionInputDto.new(
      message_id:    params[:message_id],
      user_id:       params[:user_id],
      reaction_type: params[:reaction_type]
    )

    ReactionDomain::UseCases::RemoveReaction.new(
      reaction_repository: ReactionDomain::Repositories::ReactionRepository.new
    ).call(input_dto)

    render json: { message: "Reação removida com sucesso" }, status: :ok
  rescue CleanArch::Domains::DomainError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end