class UsersController < ApplicationController
  DomainFromUser = ::CleanArch::Domains::UserDomain

  def create
    input_dto = DomainFromUser::Dtos::RegisterUserInputDto.new(
      username: params[:username]
    )

    output_dto = DomainFromUser::UseCases::RegisterUser.new(
      user_repository: DomainFromUser::Repositories::UserRepository.new
    ).call(input_dto)

    render json: output_dto.to_h, status: :created
  rescue CleanArch::Domains::DomainError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def authenticate
    input_dto = DomainFromUser::Dtos::RegisterUserInputDto.new(
      username: params[:username]
    )

    output_dto = DomainFromUser::UseCases::AuthenticateUser.new(
      user_repository: DomainFromUser::Repositories::UserRepository.new
    ).call(input_dto)

    render json: output_dto.to_h, status: :ok
  rescue CleanArch::Domains::DomainError => e
    render json: { error: e.message }, status: :unauthorized
  end

  def destroy
    output_dto = DomainFromUser::UseCases::DeactivateUser.new(
      user_repository: DomainFromUser::Repositories::UserRepository.new
    ).call(user_id: params[:id])

    render json: output_dto.to_h, status: :ok
  rescue CleanArch::Domains::DomainError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end