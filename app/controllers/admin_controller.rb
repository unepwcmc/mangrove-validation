class AdminController < ApplicationController
  before_filter :authenticate

  def index
    @layers = Layer.select("DISTINCT(email) AS email").order(:email)
  end

  def download_user_edits
    send_data Layer.user_edits_csv, :filename => "validation_user_edits.csv", :type => "application/csv"
  end

  private
    def authenticate
      authenticate_with_http_basic { |u, p| !APP_CONFIG['admins'].select{ |a| a['login'] == u && a['password'] == p }.empty? } || request_http_basic_authentication
    end
end
