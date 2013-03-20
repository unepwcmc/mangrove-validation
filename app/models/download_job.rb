class DownloadJob
  @queue = :download_serve

  def self.perform(id)
    DownloadJob.new(id)
  end

  def initialize(id)
    download = UserGeoEditDownload.find(id)
    puts "Generating download for ID #{download.id} (Name: #{download.name}; Islands: #{download.island_ids}) at #{Time.now}"

    @id = download.id

    island_count = DownloadJob.get_island_count(download.island_ids)
    puts "Processing #{island_count} island geometries"

    0.upto (island_count/APP_CONFIG['admin_user_edits_limit']).round do |offset|
      File.open(temp_file_name(offset), "w+") do |file|
        puts "Retrieving geojson for #{offset + 1}/#{(island_count / APP_CONFIG['admin_user_edits_limit']) + 1}"
        file << DownloadJob.get_islands(download.island_ids, offset)
      end

      generate_shapefiles(offset)
    end

    generate_zipfile()

    puts "Successfully generated download for ID #{@id}"
    download.update_attributes(:status => :finished)

    begin
      puts "Sending notification mail to #{download.user.email}"
      DownloadNotifier.download_email(download).deliver
    rescue Exception => msg
      puts "***** Mail Delivery FAILED *****"
      puts "Cannot deliver email:"
      puts msg
      puts msg.backtrace
      puts "********************************"
    end
  rescue Exception => msg
    puts "***** Download FAILED *****"
    puts msg
    puts msg.backtrace
    puts "***************************"
    download.update_attributes(:status => :failed)
  ensure
    cleanup()
  end

  def self.get_islands(ids, offset)
    query = "SELECT * FROM #{APP_CONFIG['cartodb_table']}"
    query << " WHERE island_id IN (#{ids})" if !ids.empty?
    query << " LIMIT #{APP_CONFIG['admin_user_edits_limit']} OFFSET #{offset * APP_CONFIG['admin_user_edits_limit']}"

    uri = URI.parse(URI.escape("http://carbon-tool.cartodb.com/api/v1/sql?q=#{query}&format=geojson"))
    res = Net::HTTP.get_response(uri)

    return res.body.force_encoding('UTF-8')
  end

  def self.get_island_count(ids)
    query =  "SELECT COUNT(*) FROM #{APP_CONFIG['cartodb_table']}"
    query << " WHERE island_id IN (#{ids})" if !ids.empty?

    uri = URI.parse(URI.escape("http://carbon-tool.cartodb.com/api/v1/sql?q=#{query}"))
    res = Net::HTTP.get_response(uri)

    return JSON.parse(res.body)["rows"].first["count"]
  end

  def generate_shapefiles(offset)
    dir = "#{job_directory}/#{offset}"
    FileUtils.mkdir_p dir unless File.exists?(dir)

    system "ogr2ogr -skipfailures -f 'ESRI Shapefile' #{dir} #{temp_file_name(offset)}"
    if $? != 0
      raise Exception, "ogr2ogr failed"
    end

    ogr_command = "ogr2ogr "
    ogr_command << "-update -append " if offset>0
    ogr_command << "#{job_directory}/all.shp #{dir}/OGRGeoJSON.shp"

    system ogr_command
    if $? != 0
      raise Exception, "ogr2ogr failed"
    end
  end

  def cleanup
    FileUtils.rm_rf(job_directory)
    FileUtils.rm_rf(temp_file_name("*"))
  end

  def generate_zipfile
    system "zip -j #{zip_path} #{job_directory}/all.*"
    if $? != 0
      raise Exception, "Zip failed"
    end
  end

  def temp_file_name(offset)
    "#{Rails.root}/tmp/download#{@id}-#{offset}.json"
  end

  def download_directory
    path = "#{Rails.root}/public/exports"
    FileUtils.mkdir_p path unless File.exists?(path)
    path
  end

  def job_directory
    path = "#{download_directory}/#{@id}"
    FileUtils.mkdir_p path unless File.exists?(path)
    path
  end

  def zip_path
    "#{job_directory}.zip"
  end
end
