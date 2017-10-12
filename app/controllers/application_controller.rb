class ApplicationController < ActionController::API

  before_action :check_auth_token

  private
  def check_auth_token
    if params[:auth_token].blank?
      render json: { message: "Auth token can't be blank", status: false, code: 400 }
    elsif params[:auth_token] != Rails.application.secrets.auth_token
      render json: { message: "Incorrect token", status: :unauthorized, code: 401 }
    end 
  end
end
