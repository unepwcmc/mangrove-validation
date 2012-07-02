class IslandsController < ApplicationController
  before_filter :authenticate_user!, :only => :create
  respond_to :json

  def index
    @islands = Island.filter(params).limit(4)
    respond_with @islands
  end

  def create
    @island = Island.create(params[:island])

    if @island.save
      respond_with @island
    elsif
      render text: 'Not saved', :status => :unprocessable_entity
    end
  end

  def show
    @island = Island.find(params[:id])
    respond_with @island
  end

  def update
    @island = Island.find(params[:id])
    @island.update_attributes(params[:island])
    
    respond_with @island
  end
end
