class AdminController < ApplicationController
  before_filter :authenticate

  def index
    @layers = Layer.select("DISTINCT(email) AS email").order(:email)
  end

  def download_user_edits
    output = Layer.user_edits
    send_file output, :filename => "user_edits.zip", :type => "application/zip"
  end

  private
    def authenticate
      authenticate_with_http_basic { |u, p| !APP_CONFIG['admins'].select{ |a| a['login'] == u && a['password'] == p }.empty? } || request_http_basic_authentication
    end
end
