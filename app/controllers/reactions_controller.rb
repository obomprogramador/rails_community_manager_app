class ReactionsController < ApplicationController
  ReactionDomain = CleanArch::Domains::ReactionDomain

  def index
    puts "\n\n\n\n"
    pp "PASSOU NO INDEX DO REACTIONS CONTROLLER"
    pp session[:user_id]
    pp Reaction.find_by(message_id: 1, user_id: session[:user_id])&.reaction_type
    puts "\n\n\n\n"
    
    output = ReactionDomain::UseCases::ListMessageReactions.new(
      reaction_repository: ReactionDomain::Repositories::ReactionRepository.new
    ).call(message_id: params[:message_id])

    render json: output.map(&:to_h), status: :ok
  rescue CleanArch::Domains::DomainError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def create
    puts "\n\n\n\n"
    pp "PASSOU NO CREATE DO REACTIONS CONTROLLER"
    pp session[:user_id]
    pp Reaction.find_by(message_id: 1, user_id: session[:user_id])&.reaction_type
    puts "\n\n\n\n"
    repository = ReactionDomain::Repositories::ReactionRepository.new
    message_id = params[:message_id]
    user_id    = params[:user_id]

    validated_type = ReactionDomain::ValueObjects::ReactionType.new(params[:reaction_type]).value

    if repository.exists?(
      message_id:    message_id,
      user_id:       user_id,
      reaction_type: validated_type
    )
      remove_dto = ReactionDomain::Dtos::RemoveReactionInputDto.new(
        message_id:    message_id,
        user_id:       user_id,
        reaction_type: params[:reaction_type]
      )
      ReactionDomain::UseCases::RemoveReaction.new(reaction_repository: repository).call(remove_dto)

      ActionCable.server.broadcast(
        "message_reactions_#{message_id}",
        {
          type:          "reaction_removed",
          message_id:    message_id.to_i,
          user_id:       user_id.to_i,
          reaction_type: validated_type
        }
      )

      respond_to do |format|
        format.turbo_stream { render turbo_stream: replace_reactions_stream(message_id, params[:community_id]) }
        format.json do
          render json: {
            removed:       true,
            message_id:    message_id.to_i,
            reaction_type: validated_type
          }, status: :ok
        end
        format.html { redirect_back_reactions(notice: "Reação removida.") }
      end
    else
      add_dto = ReactionDomain::Dtos::AddReactionInputDto.new(
        message_id:    message_id,
        user_id:       user_id,
        reaction_type: params[:reaction_type]
      )

      output = ReactionDomain::UseCases::AddReaction.new(reaction_repository: repository).call(add_dto)

      ActionCable.server.broadcast(
        "message_reactions_#{message_id}",
        { type: "reaction_added", reaction: output.to_h }
      )

      respond_to do |format|
        format.turbo_stream { render turbo_stream: replace_reactions_stream(message_id, params[:community_id]) }
        format.json { render json: output.to_h, status: :created }
        format.html { redirect_back_reactions }
      end
    end
  rescue ArgumentError => e
    respond_to_reaction_error(CleanArch::Domains::DomainError.new(e.message))
  rescue CleanArch::Domains::DomainError => e
    respond_to_reaction_error(e)
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

    respond_to do |format|
      format.json { render json: { message: "Reação removida com sucesso" }, status: :ok }
      format.html { redirect_back_reactions(notice: "Reação removida com sucesso") }
    end
  rescue CleanArch::Domains::DomainError => e
    respond_to_reaction_error(e)
  end

  private

  # def replace_reactions_stream(message_id, community_id)
  #   turbo_stream.replace(
  #     "reactions_#{message_id}",
  #     partial: "reactions/reactions",
  #     locals: { message_id: message_id, community_id: community_id }
  #   )
  # end

  def replace_reactions_stream(message_id, community_id)
    user_reaction = Reaction.find_by(
      message_id: message_id,
      user_id: session[:user_id]
    )&.reaction_type
  
    turbo_stream.replace(
      "reactions_#{message_id}",
      partial: "reactions/reactions",
      locals: {
        message_id: message_id,
        community_id: community_id,
        user_reaction: user_reaction
      }
    )
  end

  def redirect_back_reactions(**opts)
    redirect_back(
      fallback_location: community_messages_path(params[:community_id]),
      status:            :see_other,
      **opts
    )
  end

  def respond_to_reaction_error(error)
    message_id = params[:message_id]
    respond_to do |format|
      format.turbo_stream do
        flash.now[:alert] = error.message
        render turbo_stream: [
          turbo_stream.replace("flash_messages", partial: "layouts/flash_messages"),
          turbo_stream.replace(
            "reactions_#{message_id}",
            partial: "reactions/reactions",
            locals: { message_id: message_id, community_id: params[:community_id] }
          )
        ]
      end
      format.json { render json: { error: error.message }, status: :unprocessable_entity }
      format.html { redirect_back_reactions(alert: error.message) }
    end
  end
end
