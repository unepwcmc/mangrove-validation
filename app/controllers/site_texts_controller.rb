class SiteTextsController < ApplicationController
  def update
    @site_text = SiteText.find(params[:id])
    @site_text.text = params[:site_text][:text]
    @site_text.save
    redirect_to :admin
  end
end
