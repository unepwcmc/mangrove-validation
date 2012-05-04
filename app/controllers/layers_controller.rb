class LayersController < ApplicationController
  before_filter :authenticate_user!, :only => :create

  respond_to :html, :only => :index
  respond_to :json, :only => :create

  def index
    @layer = Layer.new
    respond_with @layer
  end

  def create
    @layer = Layer.new(params[:layer])
    @layer.name = params[:layer][:name].to_i
    @layer.action = params[:layer][:action].to_i
    @layer.user = current_user
    @layer.save
    respond_with @layer
  end
end
