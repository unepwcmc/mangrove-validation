namespace :downloads do
  task :setup => :environment

  desc "remove all active downloads from the database"
  task :clear_active => :environment do
    UserGeoEditDownload.destroy_all(:status => 'active')
  end
end
