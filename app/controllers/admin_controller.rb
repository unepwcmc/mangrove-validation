class AdminController < ApplicationController
  before_filter :authenticate
  #before_filter :ensure_background_machine

  def index
    @user_layers = Layer.select("DISTINCT(user_id) AS user_id")
    @community_layer_files = [
      LayerFile.new(APP_CONFIG['cartodb_table'], Names::MANGROVE, Status::VALIDATED),
      LayerFile.new(APP_CONFIG['cartodb_table'], Names::CORAL, Status::VALIDATED),
      LayerFile.new(APP_CONFIG['cartodb_table'], Names::MANGROVE, Status::USER_EDITS),
      LayerFile.new(APP_CONFIG['cartodb_table'], Names::CORAL, Status::USER_EDITS)
    ]
    current_jobs = Resque.peek('statused', 0, 20)
    @user_job ={}
    current_jobs.each do |cj|
      job_parameters = cj['args'].last
      puts job_parameters.inspect
      is_community_layer = false
      # Try to reconcile jobs with community layer
      @community_layer_files.each do |glf|
        if glf.cartodb_table == job_parameters['cartodb_table'] &&
            glf.layer_name == job_parameters['layer_name'] &&
            glf.layer_status == job_parameters['layer_status']
          glf.job_id = cj['args'].first
          is_common_layer = true
          next
        end
      end
      # If it's not a community layer, create a new layer file
      unless is_community_layer
        # TODO
      end
    end
  end

  def get_job_status
    render :json => Resque::Plugins::Status::Hash.get(params[:job_id])
  end

  def generate_from_cartodb
    job_params = {
      :cartodb_table => APP_CONFIG['cartodb_table'],
      :layer_name => params[:name].to_i,
      :layer_status => params[:status].to_i,
      :email => params[:email]
    }
    job_id = LayerFileJob.create(job_params)
    redirect_to({:action => :index, :job_id => job_id})
  end

  def download_from_cartodb
    output = LayerFile.new(APP_CONFIG['cartodb_table'], params[:name].to_i, params[:status].to_i, params[:email])
    send_file output.zip_path, :filename => output.zip_name, :type => "application/zip"
  end

 private
    def authenticate
      authenticate_with_http_basic { |u, p| !APP_CONFIG['admins'].select{ |a| a['login'] == u && a['password'] == p }.empty? } || request_http_basic_authentication
    end
    def ensure_background_machine
      unless request.host_with_port == APP_CONFIG['background_machine']
        redirect_to "http://#{APP_CONFIG['background_machine']}/admin"
      end
    end
end
