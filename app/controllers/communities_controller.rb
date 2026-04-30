class CommunitiesController < ApplicationController
  CommunityDomain = ::CleanArch::Domains::CommunityDomain

  def index
    output = CommunityDomain::UseCases::ListCommunities.new(
      community_repository: CommunityDomain::Repositories::CommunityRepository.new
    ).call

    respond_to do |format|
      format.html { @communities = output }
      format.json { render json: output.map(&:to_h), status: :ok }
    end
  end

  def create
    input_dto = CommunityDomain::Dtos::CreateCommunityInputDto.new(
      name:        params[:name],
      description: params[:description]
    )

    output = CommunityDomain::UseCases::CreateCommunity.new(
      community_repository: CommunityDomain::Repositories::CommunityRepository.new
    ).call(input_dto)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.prepend(
          "communities_list",
          partial: "communities/community",
          locals: { community: output }
        )
      end

      format.html do
        redirect_to communities_path, notice: "Comunidade criada com sucesso."
      end

      format.json { render json: output.to_h, status: :created }
    end
  rescue CleanArch::Domains::DomainError, ArgumentError => e
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "community_form_error",
          partial: "shared/error",
          locals: { message: e.message }
        ), status: :unprocessable_entity
      end

      format.html do
        @communities = CommunityDomain::UseCases::ListCommunities.new(
          community_repository: CommunityDomain::Repositories::CommunityRepository.new
        ).call

        flash.now[:alert] = e.message
        render :index, status: :unprocessable_entity
      end

      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end

  def update
    input_dto = CommunityDomain::Dtos::UpdateCommunityInputDto.new(
      id:          params[:id],
      name:        params[:name],
      description: params[:description]
    )

    output = CommunityDomain::UseCases::UpdateCommunity.new(
      community_repository: CommunityDomain::Repositories::CommunityRepository.new
    ).call(input_dto)

    render json: output.to_h, status: :ok
  rescue CleanArch::Domains::DomainError, ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def search
    input_dto = CommunityDomain::Dtos::SearchCommunityInputDto.new(
      query: params[:query]
    )

    output = CommunityDomain::UseCases::SearchCommunities.new(
      community_repository: CommunityDomain::Repositories::CommunityRepository.new
    ).call(input_dto)

    render json: output.map(&:to_h), status: :ok
  rescue CleanArch::Domains::DomainError, ArgumentError => e
    render json: { error: e.message }, status: :not_found
  end
end