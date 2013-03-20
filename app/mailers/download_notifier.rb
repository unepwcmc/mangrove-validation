class DownloadNotifier < ActionMailer::Base
  helper :UserGeoEdits

  default from: "no-reply@unep-wcmc.org"

  def download_email(download)
    @user = download.user
    @download = download

    mail(:to => @user.email,
         :subject => "Your Global Islands Database download is complete!",
         :template_path => "download_notifier",
         :template_name => "download_notifier")
  end
end
