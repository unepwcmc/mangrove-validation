class DownloadController < ApplicationController
  before_filter :authenticate_user!

  def generate
    if params[:range] == 'user_edits'
      island_ids = UserGeoEdit.
        where(:user_id => current_user.id).
        select(:island_id).
        map(&:island_id).
        join(',')
      name = "Islands I've Edited"
      user = current_user
    else # All
      user = nil
      name = "All Islands"
      island_ids = ''
    end

    user_geo_edit_download = UserGeoEditDownload.create(
      :name => name,
      :user => user,
      :island_ids => island_ids,
      :status => :active
    )

    Resque.enqueue(DownloadJob, user_geo_edit_download.id)

    redirect_to :back
  end

  def available
    @all_islands_download = UserGeoEditDownload.
      where("user_id = ?", nil).
      where("status IN ('active', 'finished')").
      order("created_at DESC").
      first

    @user_download = UserGeoEditDownload.
      where("user_id = ? AND status IN ('active', 'finished')", current_user.id).
      order("created_at DESC").
      first

    render "index"
  end
end
