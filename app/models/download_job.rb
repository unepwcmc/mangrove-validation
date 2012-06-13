class DownloadJob
  @queue = :download_serve

  def self.perform(options)
    require 'net/http'
    require 'uri'

    user_geo_edit_download = UserGeoEditDownload.find(options['user_geo_edit'])

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

      Tempfile.open(['download', '.json']) do |file|
        0.upto (count/APP_CONFIG['admin_user_edits_limit']).round do |offset|
          query = "SELECT * FROM #{APP_CONFIG['cartodb_table']}"
          query << " WHERE #{where_clause}" if !user_geo_edit_download.island_ids.empty?
          query << " LIMIT #{APP_CONFIG['admin_user_edits_limit']} OFFSET #{offset * APP_CONFIG['admin_user_edits_limit']}"
          uri = URI.parse(URI.escape("http://carbon-tool.cartodb.com/api/v1/sql?q=#{query}&format=geojson"))
          res = Net::HTTP.get_response(uri)
          file << res.body
        end

        file.rewind

        ogr2ogr_dir = self.ogr2ogr_directory(:user_geo_edit, user_geo_edit_download.id)

        # Debug
        # system "cp #{file.path} ~/Desktop"

        system "ogr2ogr -overwrite -skipfailures -f 'ESRI Shapefile' #{ogr2ogr_dir} #{file.path}"
        system "zip -j #{self.zip_path(:user_geo_edit, user_geo_edit_download.id)} #{ogr2ogr_dir}/*"
        system "mv #{self.zip_path(:user_geo_edit, user_geo_edit_download.id)} #{self.download_directory(:user_geo_edit)}"

        user_geo_edit_download.update_attributes(:status => :finished)
      end
    rescue
      puts "Failed"
      user_geo_edit_download.update_attributes(:status => :failed)
    end
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
