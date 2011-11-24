class UsersController < ApplicationController
  before_filter :require_user, :except => [:new, :create] 
  
  def new
    @user = User.new
    render :layout => "main"
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Successfully created user."
      redirect_to games_url
    else
      render :action => 'new'
    end
  end
  
  def edit
    @user = User.find(params[:id])
    render :layout => "main"
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated user."
      redirect_to root_url
    else
      render :action => 'edit'
    end
  end
  
  def rank
    users = User.all :conditions => "rank > #{current_user.rank-15} AND rank < #{current_user.rank + 15}", :order => 'rank ASC'    
    json = users.inject([]) {|a,u| a << u.game_json(current_user) }    
    render :json => json, :callback => params[:callback] 
  end
end
