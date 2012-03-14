class AdminController < ApplicationController
  before_filter :authenticate
  before_filter :ensure_background_machine

  def index
    @layers = Layer.select("DISTINCT(email) AS email").order(:email)
    @generated_layer_files = [
      LayerFile.new(Names::MANGROVE, Status::VALIDATED),
      LayerFile.new(Names::CORAL, Status::VALIDATED),
      LayerFile.new(Names::MANGROVE, Status::USER_EDITS),
      LayerFile.new(Names::CORAL, Status::USER_EDITS)
    ]
  end

  def generate_from_cartodb
    output = LayerFile.new(params[:name].to_i, params[:status].to_i, params[:email])
    output.generate
    send_file output.zip_path, :filename => output.zip_name, :type => "application/zip"
  end

  def download_from_cartodb
    output = LayerFile.new(params[:name].to_i, params[:status].to_i, params[:email])
    send_file output.zip_path, :filename => output.zip_name, :type => "application/zip"
  end

 private
    def authenticate
      authenticate_with_http_basic { |u, p| !APP_CONFIG['admins'].select{ |a| a['login'] == u && a['password'] == p }.empty? } || request_http_basic_authentication
    end
    def ensure_background_machine
      puts request.host_with_port
      puts APP_CONFIG['background_machine']
      unless request.host_with_port == APP_CONFIG['background_machine']
        redirect_to "http://#{APP_CONFIG['background_machine']}/admin"
      end
    end
end
