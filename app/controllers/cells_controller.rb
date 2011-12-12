class CellsController < ApplicationController
  def tiles
    cells = Cell.all :conditions => {:parent_x => params[:x], :parent_y => params[:y], :parent_z => params[:z], :mangroves => true}
    mangroves = cells.inject([]) { |a,c| a << c.game_json }
    
    # FIX: temp to get some cells...
    user_cells = Cell.find(:all, :joins => [:classifications, :tracks], :conditions => ["cells.id = classifications.cell_id AND classifications.track_id = tracks.id AND tracks.user_id = ?", current_user.id])
    user_selections = user_cells.inject([]) { |a,c| a << c.game_json }

    render :json => {mangroves: mangroves, user_selections: user_selections}, :callback => params[:callback]
  end
end