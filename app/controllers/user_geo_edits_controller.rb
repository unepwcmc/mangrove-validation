class UserGeoEditsController < ApplicationController
  before_filter :authenticate_user!, :only => [:create]

  respond_to :html, :only => [:index, :user_downloads]
  respond_to :json, :only => [:create, :reallocate_geometry]

  def index
    @user_geo_edit = UserGeoEdit.new

    @user_geo_edits_count = 0
    @user_geo_edits_count = current_user.user_geo_edits.count if current_user

    respond_with @user_geo_edit
  end

  def create
    @user_geo_edit = UserGeoEdit.new(params[:user_geo_edit])
    @user_geo_edit.user = current_user
    @user_geo_edit.save

    respond_with @user_geo_edit
  end

  def user_navbar_links
    render :partial => "navbar_user"
  end

  def reallocate_geometry
    # Get the island to reallocate based on ID if input is numerica
    if !((params[:reallocate_to_island_name] =~ /^[0-9]+$/).nil?)
      @destination_island = Island.find_by_id(params[:reallocate_to_island_name])
    else
      # Get/Create the island to reallocate to
      @destination_island = Island.find_or_create_by_name(params[:reallocate_to_island_name])
    end

    # Reallocate the poly to destination island
    @destination_reallocate = UserGeoEdit.new(
      :polygon => params[:reallocate_polygon],
      :knowledge => params[:reallocate_knowledge],
      :island_id => @destination_island.id,
      :reallocated_from_island_id => params[:reallocate_from_island_id],
      :action => 'reallocate',
      :user => current_user
    )

    # Remove the poly from the current island
    @from_delete = UserGeoEdit.new(
      :polygon => params[:reallocate_polygon],
      :knowledge => params[:reallocate_knowledge],
      :island_id => params[:reallocate_from_island_id].to_i,
      :action => 'delete',
      :user => current_user
    )

    if !@destination_reallocate.save 
      respond_with @destination_reallocate
    elsif !@from_delete.save
      respond_with @from_delete
    else
      respond_with @destination_island
    end
  end
end
