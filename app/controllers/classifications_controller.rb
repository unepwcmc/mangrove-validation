class ClassificationsController < ApplicationController
  before_filter :require_user
  
  def create
    # Create track assigned to user
    track = Track.new()
    track.user_id = current_user.id
    track.save!

    params[:selection].each do |selection|
      cell = Cell.find_or_create_by_x_and_y_and_z(selection[1][:x], selection[1][:y], 17)
      # Create classification assigned to track and cell
      classification = Classification.new()
      classification.track_id = track.id
      classification.cell_id = cell.id
      classification.value = selection[1][:value]
      classification.save!
    end
    
    render :json => {:ok => true}
  end
  
  def update
    @classification = Classification.find(params[:id], :include => [{:track => :user}, :cell])    

    if @classification.update_attributes(:value => params[:value]) && current_user.tracks.include?(@classification.track)
      render :json => {:update => true}, :callback => params[:callback]  
    else
      render :json => {:update => false}, :callback => params[:callback]  
    end
  end
end
