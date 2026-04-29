class CommunityMembersController < ApplicationController
  CommunityMemberDomain = CleanArch::Domains::CommunityMemberDomain

  def index
    output = CommunityMemberDomain::UseCases::ListCommunityMembers.new(
      community_member_repository: CommunityMemberDomain::Repositories::CommunityMemberRepository.new
    ).call(community_id: params[:community_id])

    render json: output.map(&:to_h), status: :ok
  rescue CleanArch::Domains::DomainError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def create
    input_dto = CommunityMemberDomain::Dtos::JoinCommunityInputDto.new(
      community_id: params[:community_id],
      user_id:      params[:user_id]
    )

    output = CommunityMemberDomain::UseCases::JoinCommunity.new(
      community_member_repository: CommunityMemberDomain::Repositories::CommunityMemberRepository.new
    ).call(input_dto)

    render json: output.to_h, status: :created
  rescue CleanArch::Domains::DomainError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def destroy
    input_dto = CommunityMemberDomain::Dtos::MemberActionInputDto.new(
      community_id: params[:community_id],
      user_id:      params[:user_id]
    )

    CommunityMemberDomain::UseCases::LeaveCommunity.new(
      community_member_repository: CommunityMemberDomain::Repositories::CommunityMemberRepository.new
    ).call(input_dto)

    render json: { message: "Saiu da comunidade com sucesso" }, status: :ok
  rescue CleanArch::Domains::DomainError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def promote
    input_dto = CommunityMemberDomain::Dtos::MemberActionInputDto.new(
      community_id: params[:community_id],
      user_id:      params[:user_id]
    )

    output = CommunityMemberDomain::UseCases::PromoteMember.new(
      community_member_repository: CommunityMemberDomain::Repositories::CommunityMemberRepository.new
    ).call(input_dto)

    render json: output.to_h, status: :ok
  rescue CleanArch::Domains::DomainError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def demote
    input_dto = CommunityMemberDomain::Dtos::MemberActionInputDto.new(
      community_id: params[:community_id],
      user_id:      params[:user_id]
    )

    output = CommunityMemberDomain::UseCases::DemoteMember.new(
      community_member_repository: CommunityMemberDomain::Repositories::CommunityMemberRepository.new
    ).call(input_dto)

    render json: output.to_h, status: :ok
  rescue CleanArch::Domains::DomainError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def ban
    input_dto = CommunityMemberDomain::Dtos::MemberActionInputDto.new(
      community_id: params[:community_id],
      user_id:      params[:user_id]
    )

    output = CommunityMemberDomain::UseCases::BanMember.new(
      community_member_repository: CommunityMemberDomain::Repositories::CommunityMemberRepository.new
    ).call(input_dto)

    render json: output.to_h, status: :ok
  rescue CleanArch::Domains::DomainError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end