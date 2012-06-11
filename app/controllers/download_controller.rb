class DownloadController < ApplicationController

  def generate
    case params[:range]
    when 'user_edits'
      island_ids = '5'# get island 
    else
      island_ids = '5'
    end

    user_geo_edit_download = UserGeoEditDownload.create(:user => current_user, :island_ids => island_ids)
    Resque.enqueue(DownloadJob, {:user_geo_edit => user_geo_edit_download.id})

    redirect_to :back
  end

  def download
  end
end
