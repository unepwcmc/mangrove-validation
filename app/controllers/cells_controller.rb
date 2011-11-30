class CellsController < ApplicationController
  def tiles
    cells = Map.all :conditions => {:parent_x => params[:x], :parent_y => params[:y], :parent_z => params[:z]}
    json = cells.inject([]) { |a,c| a << c.game_json }
    render :json => json, :callback => params[:callback]
  end
end