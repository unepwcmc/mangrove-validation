class AdminController < ApplicationController
  before_filter :authenticate
  before_filter :ensure_background_machine

  def index
    @layer_downloads = LayerDownload.order(:id)
    @users = User.all
  end

#  def get_job_status
#    render :json => Resque::Plugins::Status::Hash.get(params[:job_id])
#  end

  # Generates download file from CartoDB
  def generate
    if params[:layer]
      layer_download = LayerDownload.find(params[:layer])
      layer_download.update_attributes(generated_at: Time.now, finished: false)
      Resque.enqueue(DownloadJob, {:layer => layer_download.id})
    else
      user = User.find(params[:user])
      user.update_attributes(generated_at: Time.now, finished: false)
      Resque.enqueue(DownloadJob, {:user => user.id})
    end

    redirect_to :action => :index
  end

  # Downloads file generated from CartoDB
  def download
    if params[:layer]
      send_file DownloadJob.zip_path(:layer, params[:layer]), type: 'application/zip'
    else
      send_file DownloadJob.zip_path(:user, params[:user]), type: 'application/zip'
    end
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
