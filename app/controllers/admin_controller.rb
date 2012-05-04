class AdminController < ApplicationController
  before_filter :authenticate
  before_filter :ensure_background_machine

  def index
    @layer_downloads = LayerDownload.order(:name)
    @users = User.order(:email)
  end

  # Generates download file from CartoDB
  def generate
    if params[:layer]
      layer_download = LayerDownload.find(params[:layer])
      layer_download.update_attributes(generated_at: Time.now, finished: false)
      Resque.enqueue(DownloadJob, {:layer => layer_download.id})
    else # user
      user = User.find(params[:user])
      user.update_attributes(generated_at: Time.now, finished: false)
      Resque.enqueue(DownloadJob, {:user => user.id})
    end

    redirect_to :action => :index
  end

  # Downloads file generated from CartoDB
  def download
    if params[:layer]
      layer_download = LayerDownload.find(params[:layer])
      send_file DownloadJob.zip_path(:layer, params[:layer]), filename: "#{layer_download.name}.zip", type: 'application/zip'
    else # user
      user = User.find(params[:user])
      send_file DownloadJob.zip_path(:user, params[:user]), filename: "#{user.email}.zip", type: 'application/zip'
    end
  end
  
  def download_users
    require 'csv'

    users = CSV.generate do |csv|
      csv << ['NAME', 'EMAIL', 'INSTITUTION', 'EDITS']
      User.order(:email).each do |user|
        csv << [user.name, user.email, user.institution, user.layers.count]
      end
    end

    send_data users, filename: 'users.csv', type: 'text/csv; charset=utf-8; header=present'
  end

  private
    def authenticate
      authenticate_with_http_basic { |u, p| !APP_CONFIG['admins'].select{ |a| a['login'] == u && a['password'] == p }.empty? } || request_http_basic_authentication
    end

    def ensure_background_machine
      if Rails.env == 'production' && request.host_with_port != APP_CONFIG['background_machine']
        redirect_to "http://#{APP_CONFIG['background_machine']}/admin"
      end
    end
end
