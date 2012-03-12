class AdminController < ApplicationController
  before_filter :authenticate

  def index
    @layers = Layer.select("DISTINCT(email) AS email").order(:email)
  end

  def generate_from_cartodb
    output = Layer.get_from_cartodb(params[:name].to_i, params[:status].to_i, params[:email])
    send_file output, :filename => Layer.zip_file_name(params[:name].to_i, params[:status].to_i, params[:email]), :type => "application/zip"
  end

  def download_from_cartodb
    output = Layer.zip_file_path(params[:name].to_i, params[:status].to_i, params[:email])
    send_file output, :filename => Layer.zip_file_name(params[:name].to_i, params[:status].to_i, params[:email]), :type => "application/zip"
  end

 private
    def authenticate
      authenticate_with_http_basic { |u, p| !APP_CONFIG['admins'].select{ |a| a['login'] == u && a['password'] == p }.empty? } || request_http_basic_authentication
    end
end
