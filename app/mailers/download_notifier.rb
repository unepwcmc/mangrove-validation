class DownloadNotifier < ActionMailer::Base
  helper :UserGeoEdits

  default from: "no-reply@unep-wcmc.org"

  def download_email(download)
    @user = download.user
    @download = download
    attachments['General_Data_License_UNEP-WCMC.pdf'] = File.read("#{Rails.root}/public/exports/General_Data_License_UNEP-WCMC.pdf")
    attachments['MetadataInformation.zip'] = File.read("#{Rails.root}/public/exports/MetadataInformation.zip")

    mail(:to => @user.email,
         :subject => "Your Global Islands Database download is complete!",
         :template_path => "download_notifier",
         :template_name => "download_notifier")
  end
end
