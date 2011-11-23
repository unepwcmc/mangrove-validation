class MainController < ApplicationController
  before_filter :require_user, :only => [:main] 

  def index
    @user_session = UserSession.new
    if current_user
      redirect_to games_path
    end
  end
end
