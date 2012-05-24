class IslandsController < ApplicationController
  respond_to :json

  def index
    @islands = Island.all
    respond_with @islands
  end
end
