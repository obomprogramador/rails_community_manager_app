module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user_id

    def connect
      self.current_user_id = find_verified_user
    end

    private

    def find_verified_user
      # Estratégia simples via cookie/session.
      # Adapte para JWT ou Devise conforme necessário.
      user_id = request.session[:user_id] || request.params[:user_id]
      # reject_unauthorized_connection unless user_id
      user_id.to_i
    end
  end
end
