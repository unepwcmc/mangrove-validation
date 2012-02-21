class LayersController < ApplicationController
  def index
    p CartoDB::Connection.table 'passed'
  end
end
