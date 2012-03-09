class AdminController < ApplicationController
  before_filter :authenticate

  def index
    @layers = Layer.select("DISTINCT(email) AS email").order(:email)
  end

  def download_from_cartodb
    output = Layer.get_from_cartodb(params[:name].to_i, params[:status].to_i, params[:email])
    send_file output, :filename => "#{params[:email] ? params[:email]+"_" : ""}#{Names.key_for(params[:name].to_i).to_s}_#{Status.key_for(params[:status].to_i).to_s}.zip", :type => "application/zip"
  end

 private
    def authenticate
      authenticate_with_http_basic { |u, p| !APP_CONFIG['admins'].select{ |a| a['login'] == u && a['password'] == p }.empty? } || request_http_basic_authentication
    end
end
