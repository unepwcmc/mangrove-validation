class DownloadJob
  @queue = :download_serve

  def self.perform(id)
    DownloadJob.new(id)
  end

  def initialize(id)
    download = UserGeoEditDownload.find(id)
    puts "Generating download for ID #{download.id} (Name: #{download.name}; Islands: #{download.island_ids}) at #{Time.now}"

    generate_download

    puts "Successfully generated download for ID #{download.id}"
    download.update_attributes(:file_id => cache_id)
    download.update_attributes(:status => :finished)

    begin
      puts "Sending notification mail to #{download.user.email}"
      DownloadNotifier.download_email(download).deliver
    rescue Exception => msg
      DownloadJob.print_error(msg)
    end
  rescue Exception => msg
    DownloadJob.print_error(msg)
    cleanup
    download.update_attributes(:status => :failed)
  end

  private

  def cleanup
    FileUtils.rm_rf(cache_file)
  end

  def generate_download
    if !File.exists?(cache_file)
      download_all_islands
      add_readme_to_download
    end
  end

  # Basic Caching System
  #
  # Generates a hash of all the current geom edits in the DB, and saves
  # the latest download with this as its filename. Allows the cache to
  # be quickly discarded if there are any new changes
  def cache_id
    require 'digest/sha1'
    edits_ids_json = UserGeoEdit.select('id').to_json

    Digest::SHA1.hexdigest(edits_ids_json)
  end

  def cache_directory
    path = "#{download_directory}/cache"
    FileUtils.mkdir_p path unless File.exists?(path)
    path
  end

  def cache_file
    return "#{cache_directory}/#{cache_id}.zip"
  end

  def download_url
    query   = URI.encode("SELECT * FROM #{APP_CONFIG['cartodb_view']}")
    api_key = CARTODB_CONFIG['api_key']
    URI.parse("http://carbon-tool.cartodb.com/api/v2/sql?q=#{query}&format=shp&api_key=#{api_key}")
  end

  def download_all_islands
    require 'open-uri'
    open(cache_file, "wb") do |fo|
      fo.print open(download_url).read
    end
  end

  def add_readme_to_download
    Dir.chdir(download_directory) do
      `zip -r #{cache_file} README.txt`
      `zip -r #{cache_file} General_Data_License_UNEP-WCMC.pdf`
    end
  end

  def download_directory
    path = "#{Rails.root}/public/exports"
    FileUtils.mkdir_p path unless File.exists?(path)
    path
  end

  def self.print_error(exception)
    puts "***** EXCEPTION *****"
    puts exception
    puts exception.backtrace
    puts "***************************"
  end
end
