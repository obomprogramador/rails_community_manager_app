class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern unless Rails.env.test?
  before_action :reject_api_requests

  private

  def use_case(klass, **repos)
    klass.new(**repos.transform_values(&:new))
  end

  def reject_api_requests
    return if Rails.env.test?

    if request.format.json? || request.content_type&.include?("application/json")
      render json: { error: "Este endpoint não é uma API. Use /api/v1/..." }, status: :not_found
    end
  end
end
