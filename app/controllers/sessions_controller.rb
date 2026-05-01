class SessionsController < ApplicationController
  def new
    # renderiza app/views/sessions/new.html.haml
  end

  def create
    input_dto = CleanArch::Domains::UserDomain::Dtos::RegisterUserInputDto.new(
      username: params[:username]
    )

    output = CleanArch::Domains::UserDomain::UseCases::AuthenticateUser.new(
      user_repository: CleanArch::Domains::UserDomain::Repositories::UserRepository.new
    ).call(input_dto)

    session[:user_id]   = output.id
    session[:username]  = output.username

    # redirect_to communities_path, notice: "Bem-vindo, #{output.username}!"
    redirect_to feed_path, notice: "Bem-vindo, #{output.username}!"
  rescue CleanArch::Domains::DomainError => e
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end

  def destroy
    session.delete(:user_id)
    session.delete(:username)
    redirect_to root_path, notice: "Sessão encerrada."
  end
end