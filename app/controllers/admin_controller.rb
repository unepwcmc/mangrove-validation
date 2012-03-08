class AdminController < ApplicationController
  before_filter :authenticate

  def index
    @emails = Layer.select(:email).order(:email).uniq
  end

  private
  def authenticate
    user = authenticate_with_http_basic { |u, p| !APP_CONFIG['admins'].select{ |a| a['login'] == u && a['password'] == p }.empty? }
    if user
      @current_user = user
    else
      request_http_basic_authentication
    end
  end
end
