class UserGeoEditsController < ApplicationController
  before_filter :authenticate_user!, :only => [:create, :user_downloads]

  respond_to :html, :only => [:index, :user_downloads]
  respond_to :json, :only => [:create, :reallocate_geometry]

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

  def user_downloads
    @downloads_all_islands = UserGeoEditDownload.find(:all,
                                          :limit => 1,
                                          :order => "created_at DESC",
                                          :conditions => ["user_id IS ? AND status IN ('active','finished')", nil])

    @downloads_user = UserGeoEditDownload.find(:all,
                                               :limit => 1,
                                               :order => "created_at DESC",
                                               :conditions => ["user_id = ? AND status IN ('active', 'finished')", current_user.id])

    render :partial => "user_downloads"
  end

  def reallocate_geometry
    # Get/Create the island to reallocate to
    @destination_island = Island.find_or_create_by_name(params[:reallocate_to_island_name])

    # Reallocate the poly to destination island
    @destination_reallocate = UserGeoEdit.new(
      :polygon => params[:reallocate_polygon],
      :knowledge => params[:reallocate_knowledge],
      :island_id => @destination_island.id,
      :reallocated_from_island_id => params[:reallocate_from_island_id],
      :action => 'reallocate',
      :user => current_user
    )
    @destination_reallocate.save

    # Remove the poly from the current island
    @from_delete = UserGeoEdit.new(
      :polygon => params[:reallocate_polygon],
      :knowledge => params[:reallocate_knowledge],
      :island_id => params[:reallocate_from_island_id].to_i,
      :action => 'delete',
      :user => current_user
    )
    @from_delete.save

    respond_with @destination_island
  end
end
