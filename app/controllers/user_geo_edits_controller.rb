class UserGeoEditsController < ApplicationController
  before_filter :authenticate_user!, :only => :create

  respond_to :html, :only => :index
  respond_to :json, :only => :create

  def index
    @user_geo_edit = UserGeoEdit.new
    @modal_text = SiteText.find_or_create_by_name('landing_modal')
    respond_with @user_geo_edit
  end

  def create
    @user_geo_edit = UserGeoEdit.new(params[:user_geo_edit])
    @user_geo_edit.island_id = params[:user_geo_edit][:island_id].to_i
    @user_geo_edit.action = params[:user_geo_edit][:action]
    @user_geo_edit.user = current_user
    @user_geo_edit.save
    respond_with @user_geo_edit
  end
end
