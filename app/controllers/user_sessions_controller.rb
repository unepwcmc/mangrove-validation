class UserSessionsController < ApplicationController
  def new
    @user_session = UserSession.new
    render :layout => "main"
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Successfully logged in."
      if session[:return_to].blank? 
        redirect_to games_url
      else
        url = session[:return_to]
        session[:return_to] = nil
        redirect_to url
      end  
    else
      render :action => 'new', :layout => "main"
    end
  end
  
  def destroy
    @user_session = UserSession.find(params[:id])
    @user_session.destroy
    flash[:notice] = "Successfully logged out."
    redirect_to root_url
  end
end
