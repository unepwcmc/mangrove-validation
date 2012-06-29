class DownloadJob
  @queue = :download_serve

  def self.perform(options)
    require 'net/http'
    require 'uri'
    require 'securerandom'
    require 'rake'

    user_geo_edit_download = UserGeoEditDownload.find(options['user_geo_edit'])
    puts "Generating download #{user_geo_edit_download.id} at #{Time.now}"

    begin
      # Where clause
      where = []
      if user_geo_edit_download.island_ids.present?
        where << ActiveRecord::Base.send(:sanitize_sql_array, ["island_id IN (#{user_geo_edit_download.island_ids})"])
      end
      where_clause = where.join(' AND ')

      # CartoDB Query
      query = "SELECT COUNT(*) FROM #{APP_CONFIG['cartodb_table']}"
      query << " WHERE #{where_clause}" if !user_geo_edit_download.island_ids.empty?
      uri = URI.parse(URI.escape("http://carbon-tool.cartodb.com/api/v1/sql?q=#{query}"))
      res = Net::HTTP.get_response(uri)

      # Result count
      count = JSON.parse(res.body)["rows"].first["count"]

      hash = SecureRandom.hex(5)
      ogr2ogr_dir = self.ogr2ogr_directory(:user_geo_edit, user_geo_edit_download.id)
      zip_dir = self.zip_path(:user_geo_edit, user_geo_edit_download.id)

      0.upto (count/APP_CONFIG['admin_user_edits_limit']).round do |offset|
        File.open(self.temp_file_name(hash, offset), 'w+') do |file|
          query = "SELECT * FROM #{APP_CONFIG['cartodb_table']}"
          query << " WHERE #{where_clause}" if !user_geo_edit_download.island_ids.empty?
          query << " LIMIT #{APP_CONFIG['admin_user_edits_limit']} OFFSET #{offset * APP_CONFIG['admin_user_edits_limit']}"
          uri = URI.parse(URI.escape("http://carbon-tool.cartodb.com/api/v1/sql?q=#{query}&format=geojson"))
          res = Net::HTTP.get_response(uri)
          file << res.body.force_encoding('UTF-8')

          puts "Processing #{offset+1}/#{count / APP_CONFIG['admin_user_edits_limit']}"
          puts "Saving to file #{file.path}"
        end

        # Debug
        # system "cp #{filename} ~/Desktop"

        puts "ogr2ogr -overwrite -skipfailures -f 'ESRI Shapefile' #{ogr2ogr_dir}/#{offset} #{self.temp_file_name(hash, offset)}"
        puts `ogr2ogr -overwrite -skipfailures -f 'ESRI Shapefile' #{ogr2ogr_dir}/#{offset} #{self.temp_file_name(hash, offset)}`
        if $? != 0 then raise end

        # Merge this shapefile with our master shapefile "all.shp"
        # Allows the very large "all islands" dataset to be downloaded
        # and converted on low memory boxes
        ogr_command = "ogr2ogr "
        ogr_command << "-update -append " if offset>0
        ogr_command << "#{ogr2ogr_dir}/all.shp #{ogr2ogr_dir}/#{offset}/OGRGeoJSON.shp"
        system ogr_command
      end

      puts "zip -j #{zip_dir} #{ogr2ogr_dir}/all.*"
      puts `zip -j #{zip_dir} #{ogr2ogr_dir}/all.*`
      if $? != 0 then raise end

      # Move the file to a download directory (in /public)
      # Replace this and self#download_directory to use something like S3
      puts "mv #{zip_dir} #{self.download_directory(:user_geo_edit)}"
      puts `mv #{zip_dir} #{self.download_directory(:user_geo_edit)}`
      if $? != 0 then raise end

      puts "Successfully generated a download for #{user_geo_edit_download.id}"
      user_geo_edit_download.update_attributes(:status => :finished)

      # Remove temporary files
      rm_tmp_cmd  = "rm -r #{Rails.root}/tmp/exports/user_geo_edit/#{user_geo_edit_download.id}/"
      rm_json_cmd = "rm -r #{Rails.root}/tmp/download#{hash}*.json"

      system(rm_tmp_cmd)
      system(rm_json_cmd)
    rescue Exception => msg
      puts msg
      user_geo_edit_download.update_attributes(:status => :failed)
    end
  end

  def self.temp_file_name(hash, num)
    "#{Rails.root}/tmp/download#{hash}-#{num}.json"
  end

  def self.download_directory(type)
    path = "#{Rails.root}/public/exports/#{type}/"
    FileUtils.mkdir_p path unless File.exists?(path)
    path
  end

  def self.ogr2ogr_directory(type, id)
    path = "#{Rails.root}/tmp/exports/#{type}/#{id}"
    FileUtils.mkdir_p path unless File.exists?(path)
    path
  end

  def self.zip_path(type, id)
    path = "#{Rails.root}/tmp/exports/#{type}"
    FileUtils.mkdir_p path unless File.exists?(path)
    "#{path}/#{id}.zip"
  end
end
