class DownloadController < ApplicationController
  before_filter :authenticate_user!
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_after_download_not_found

  def generate
    user = current_user
    name = "All Islands"
    island_ids = ''

    user_geo_edit_download = UserGeoEditDownload.create(
      :name => name,
      :user => user,
      :island_ids => island_ids,
      :status => :active
    )

    Resque.enqueue(DownloadJob, user_geo_edit_download.id)

    redirect_to :back
  end

  def show
    download = UserGeoEditDownload.find(params[:id])
    download_file = "#{Rails.root}/public/exports/cache/#{download.file_id}.zip"

    if File.exists?(download_file)
      send_file(download_file,
        :filename => "global_islands_database-#{download.created_at}.zip",
        :type => 'zip')
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def available
    @all_islands_download = UserGeoEditDownload.
      where("user_id = ?", current_user.id).
      order("created_at DESC").
      first

    render "_download_modal", :layout => false
  end

  private

  def redirect_after_download_not_found
    redirect_to root_url, notice: "Your download is unavailable, please recreate it."
  end
end
