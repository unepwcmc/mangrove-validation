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
    @layer.save
    respond_with @layer
  end

  def user_edits
    send_data Layer.user_edits_csv, :filename => "validation_user_edits.csv", :type => "application/csv"
  end
end
