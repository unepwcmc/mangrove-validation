class LayersController < ApplicationController
  respond_to :html, :only => :index
  respond_to :js, :only => :create

  # GET /layers
  # GET /layers.json
  def index
    @layer = Layer.new
    respond_with @layer
  end

  # POST /layers
  # POST /layers.json
  def create
    @layer = Layer.new(params[:layer])
    @layer.name = params[:layer][:name].to_i
    @layer.action = params[:layer][:action].to_i
    @layer.save
    respond_with @layer
  end
end
