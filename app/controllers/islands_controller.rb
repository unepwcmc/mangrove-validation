class IslandsController < ApplicationController
  respond_to :json

  def index
    @islands = Island.filter(params).limit(4)
    respond_with @islands
  end

  def show
    @island = Island.find(params[:id])
    respond_with @island
  end
end
