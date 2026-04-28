class CommunitiesController < ApplicationController
  CommunityDomain = CleanArch::Domains::CommunityDomain

  def index
    output = CommunityDomain::UseCases::ListCommunities.new(
      community_repository: CommunityDomain::Repositories::CommunityRepository.new
    ).call

    render json: output.map(&:to_h), status: :ok
  end

  def create
    input_dto = CommunityDomain::Dtos::CreateCommunityInputDto.new(
      name:        params[:name],
      description: params[:description]
    )

    output = CommunityDomain::UseCases::CreateCommunity.new(
      community_repository: CommunityDomain::Repositories::CommunityRepository.new
    ).call(input_dto)

    render json: output.to_h, status: :created
  rescue CleanArch::DomainError => e
    render json: { error: e.message }, status: :unprocessable_entity
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
  rescue CleanArch::DomainError => e
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
  rescue CleanArch::DomainError => e
    render json: { error: e.message }, status: :not_found
  end
end