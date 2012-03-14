class LayerFile
  USER_EDITS_LIMIT = 500
  attr_reader :zip_name, :zip_path, :zip_ctime, :layer_name, :layer_status
  def initialize(layer_name, layer_status, email=nil)
    @layer_name = layer_name
    @layer_status = layer_status
    @email = email

    ensure_base_path
    ensure_files_dir
    ensure_zip_dir

    @zip_name = "#{@email ? @email+"_" : ""}#{Names.key_for(@layer_name).to_s}_#{Status.key_for(@layer_status).to_s}.zip"
    @zip_path = @zip_dir + '/' + @zip_name
    if File.exists?(@zip_path)
      @zip_ctime = File.ctime(@zip_path)
    end
  end

  def title
    layer_name = Names.key_for(@layer_name).capitalize.to_s.pluralize
    layer_type = (@layer_status == Status::VALIDATED ? 'community layer' : 'user edits')
    [layer_name, layer_type, '(.shp)'].join(' ')
  end

  def generate
    require 'net/http'
    require 'uri'
    email_query = @layer_status != Status::USER_EDITS ? "" : ( !@email.blank? ? ActiveRecord::Base.send(:sanitize_sql_array, ["AND email like ?", @email]) : "AND email IS NOT NULL" )
    name_query = ActiveRecord::Base.send(:sanitize_sql_array, ["name = ?", @layer_name])
    status_query = ActiveRecord::Base.send(:sanitize_sql_array, ["status = ?", @layer_status])
    #get total count of records
    count_query = "SELECT COUNT(*) FROM #{APP_CONFIG['cartodb_table']} WHERE #{name_query} AND #{status_query}"
    url = URI.escape "http://carbon-tool.cartodb.com/api/v1/sql?q=#{count_query}"
    uri = URI.parse url
    res = Net::HTTP.get_response(uri)
    count = JSON.parse(res.body)["rows"].first["count"]
    #fetch data in batches
    tmp_path = @base_path + "/tmp.json"
    File.open(tmp_path, "w+") do |f|
      0.upto (count/USER_EDITS_LIMIT).round do |i|
        query = "SELECT * FROM #{APP_CONFIG['cartodb_table']} WHERE #{name_query} AND #{status_query} #{email_query} LIMIT #{USER_EDITS_LIMIT} OFFSET #{i}&format=geojson"
        url = URI.escape "http://carbon-tool.cartodb.com/api/v1/sql?q=#{query}"
        uri = URI.parse url
        res = Net::HTTP.get_response(uri)
        f.write res.body
      end
    end

    ogr_command = "ogr2ogr -overwrite -skipfailures -f 'ESRI Shapefile' #{@files_dir} #{tmp_path}"
    system ogr_command
    system "zip -j #{@zip_path} #{@files_dir}/*"
    @zip_path
  end

private
  def ensure_base_path
    @base_path = "#{Rails.root}/tmp/exports/user_edits"
    if !File.exists?(@base_path)
      FileUtils.mkdir_p @base_path
    end
  end

  def ensure_files_dir
    @files_dir = @base_path + "/files"
    if !File.exists?(@files_dir)
      FileUtils.mkdir_p @files_dir
    end
  end

  def ensure_zip_dir
    @zip_dir = @base_path + "/zip"
    if !File.exists?(@zip_dir)
      FileUtils.mkdir_p @zip_dir
    end
  end

end