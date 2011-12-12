class TracksController < ApplicationController
  def create
    @track = Track.create :user => current_user
    render :json => @track.game_json, :callback => params[:callback]
  end
end