class DownloadController < ApplicationController

  def generate
    case params[:range]
    when 'user_edits'
      island_ids = UserGeoEdit.find(:all, :select => "island_id", :conditions => ["user_id = ?", current_user.id]).map(&:island_id).join(",")
      name = "Islands I've Edited"
      user = current_user
    else # All
      user = nil
      name = "All Islands"
      island_ids = ''
    end

    user_geo_edit_download = UserGeoEditDownload.create(:name => name, :user => user, :island_ids => island_ids, :status => :active)
    Resque.enqueue(DownloadJob, {:user_geo_edit => user_geo_edit_download.id})

    redirect_to :back
  end

  def download
  end
end
