class DownloadJob
  @queue = :download_serve

  def self.perform(options)
    require 'net/http'
    require 'uri'

    if options['layer']
      layer_download = LayerDownload.find(options['layer'])

      # Where clause
      where = []
      where << "email IS NOT NULL" if layer_download.status == Status::USER_EDITS
      where << ActiveRecord::Base.send(:sanitize_sql_array, ["name = ?", layer_download.layer])
      where << ActiveRecord::Base.send(:sanitize_sql_array, ["status = ?", layer_download.status])
      where_clause = where.join(' AND ')

      # CartoDB Query
      query = "SELECT COUNT(*) FROM #{APP_CONFIG['cartodb_table']} WHERE #{where_clause}"
      uri = URI.parse(URI.escape("http://carbon-tool.cartodb.com/api/v1/sql?q=#{query}"))
      res = Net::HTTP.get_response(uri)

      # Result count
      count = JSON.parse(res.body)["rows"].first["count"]
      
      Tempfile.open('download') do |file|
        0.upto (count/APP_CONFIG['admin_user_edits_limit']).round do |offset|
          query = "SELECT * FROM #{APP_CONFIG['cartodb_table']} WHERE #{where_clause} LIMIT #{APP_CONFIG['admin_user_edits_limit']} OFFSET #{offset * APP_CONFIG['admin_user_edits_limit']}"
          uri = URI.parse(URI.escape("http://carbon-tool.cartodb.com/api/v1/sql?q=#{query}&format=geojson"))
          res = Net::HTTP.get_response(uri)
          file << "#{res.body}\n"
        end

        file.rewind

        ogr2ogr_dir = self.ogr2ogr_directory(:layer, layer_download.id)

        # Debug
        # system "cp #{file.path} ~/Desktop"

        p "ogr2ogr -overwrite -skipfailures -f 'ESRI Shapefile' #{ogr2ogr_dir} #{Rails.root}#{file.path}"
        system "ogr2ogr -overwrite -skipfailures -f 'ESRI Shapefile' #{ogr2ogr_dir} #{Rails.root}#{file.path}"
        system "zip -j #{self.zip_path(:layer, layer_download.id)} #{ogr2ogr_dir}/*"

        layer_download.update_attributes(finished: true)
      end
    else # user
      user = User.find(options['user'])

      # Where clause
      where = []
      where << ActiveRecord::Base.send(:sanitize_sql_array, ["email = ?", user.email])
      where_clause = where.join(' AND ')

      # CartoDB Query
      query = "SELECT COUNT(*) FROM #{APP_CONFIG['cartodb_table']} WHERE #{where_clause}"
      uri = URI.parse(URI.escape("http://carbon-tool.cartodb.com/api/v1/sql?q=#{query}"))
      res = Net::HTTP.get_response(uri)

      # Result count
      count = JSON.parse(res.body)["rows"].first["count"]
      
      Tempfile.open('download') do |file|
        0.upto (count/APP_CONFIG['admin_user_edits_limit']).round do |offset|
          query = "SELECT * FROM #{APP_CONFIG['cartodb_table']} WHERE #{where_clause} LIMIT #{APP_CONFIG['admin_user_edits_limit']} OFFSET #{offset * APP_CONFIG['admin_user_edits_limit']}"
          uri = URI.parse(URI.escape("http://carbon-tool.cartodb.com/api/v1/sql?q=#{query}&format=geojson"))
          res = Net::HTTP.get_response(uri)
          file << "#{res.body}\n"
        end

        file.rewind

        ogr2ogr_dir = self.ogr2ogr_directory(:user, user.id)

        # Debug
        # system "cp #{file.path} ~/Desktop"

        p "ogr2ogr -overwrite -skipfailures -f 'ESRI Shapefile' #{ogr2ogr_dir} #{Rails.root}#{file.path}"
        system "ogr2ogr -overwrite -skipfailures -f 'ESRI Shapefile' #{ogr2ogr_dir} #{Rails.root}#{file.path}"
        system "zip -j #{self.zip_path(:user, user.id)} #{ogr2ogr_dir}/*"

        user.update_attributes(finished: true)
      end
    end
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
