class CellsController < ApplicationController
  def tiles
    cells = Cell.all :conditions => {:parent_x => params[:x], :parent_y => params[:y], :parent_z => params[:z], :mangroves => true}
    mangroves = cells.inject([]) { |a,c| a << c.game_json }
    
    # FIX: temp to get some cells...
    user_cells = Classification.find(:all, :conditions => ["classifications.parent_x = ? AND classifications.parent_y = ? AND classifications.parent_z = ? AND classifications.value IS NOT NULL AND classifications.user_id = ?", params[:x], params[:y], params[:z], current_user.id])
    user_selections = user_cells.map { |c| c.game_json }

    render :json => {mangroves: mangroves, user_selections: user_selections}, :callback => params[:callback]
  end
end