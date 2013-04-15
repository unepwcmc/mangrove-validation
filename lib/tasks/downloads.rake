namespace :downloads do
  task :setup => :environment

  desc "Removes all but the latest download, and sets all previous downloads to use the latest file"
  task :clear_cache => :environment do
    latest_successful_downloads = UserGeoEditDownload.
      where("file_id IS NOT NULL").
      where(:status => :finished).
      order("id DESC")

    latest_successful_download = latest_successful_downloads.first
    file_id = latest_successful_download.file_id

    cache_files = Dir.glob("#{Rails.root}/public/exports/cache/*{.zip}")
    cache_files.each do |file|
      unless File.basename(file, ".*") == file_id
        FileUtils.rm_rf(file)
      end
    end

    latest_successful_downloads.each do |download|
      download.update_attribute('file_id', file_id)
    end
  end

  desc "remove all active downloads from the database"
  task :clear_active => :environment do
    UserGeoEditDownload.destroy_all(:status => 'active')
  end
end
