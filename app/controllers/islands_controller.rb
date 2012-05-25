class IslandsController < ApplicationController
  respond_to :json

  def index
    @islands = Island.filter(params)
    respond_with @islands
  end
end
