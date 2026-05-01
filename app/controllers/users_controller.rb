class UsersController < ApplicationController
  DomainFromUser = ::CleanArch::Domains::UserDomain

  def new
  end

  def create
    input_dto = DomainFromUser::Dtos::RegisterUserInputDto.new(
      username: params[:username]
    )

    output_dto = DomainFromUser::UseCases::RegisterUser.new(
      user_repository: DomainFromUser::Repositories::UserRepository.new
    ).call(input_dto)

    respond_to do |format|
      format.html do
        redirect_to new_session_path, notice: "Usuário #{output_dto.username} cadastrado com sucesso. Faça login."
      end
      format.json { render json: output_dto.to_h, status: :created }
    end
  rescue CleanArch::Domains::DomainError => e
    respond_to do |format|
      format.html do
        flash.now[:alert] = e.message
        render :new, status: :unprocessable_entity
      end
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
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