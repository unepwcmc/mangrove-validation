class AdminController < ApplicationController

  def index
    @emails = Layer.select(:email).order(:email).uniq
  end
end
