class Layer < ActiveRecord::Base
  USER_EDITS_LIMIT = 200

  validates :name, presence: true, inclusion: { in: Names.list, message: "%{value} is not a valid name" }
  validates :action, presence: true, inclusion: { in: Actions.list, message: "%{value} is not a valid action" }
  validates :polygon, presence: true
  validates :email, presence: true, format: {with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }

  before_create :cartodb

  def cartodb
    geom_sql = "ST_GeomFromText('MULTIPOLYGON(((#{polygon})))', 4326)"
    # SQL CartoDB
    case self.action
      when Actions::VALIDATE
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, name, status, action, email)
            (SELECT ST_Multi(ST_Intersection(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326))), #{name}, #{Status::VALIDATED}, #{action}, '#{email}'
              FROM #{APP_CONFIG['cartodb_table']}
              WHERE ST_Intersects(the_geom, ST_GeomFromText('SRID=4326;POLYGON((#{polygon}))', 4326)) AND status = #{Status::ORIGINAL} AND name = #{name});
          UPDATE #{APP_CONFIG['cartodb_table']} SET the_geom=ST_Multi(ST_Union(ST_Difference(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326)), ST_GeomFromEWKT('SRID=4326;POLYGON EMPTY'))) WHERE ST_Intersects(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326)) AND name = #{name} AND status = #{Status::ORIGINAL}
        SQL
      when Actions::ADD
        # Add with a hammer
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, name, status, action, email) VALUES
            (#{geom_sql}, #{name}, #{Status::VALIDATED}, #{action}, '#{email}');
        SQL
=begin
# This way should work, but we're having some carto db issues, revisit
        # Add the difference
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, name, status)
            (SELECT ST_Multi((ST_Difference(#{geom_sql}, the_geom))), #{name}, 1
              FROM #{APP_CONFIG['cartodb_table']}
              WHERE ST_Intersects(#{geom_sql}, the_geom) AND status = 1 AND name = #{name});
        SQL
        # Add the intersection
        sql = sql + <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, name, status)
            (SELECT ST_Multi((ST_Intersection(#{geom_sql}, the_geom))), #{name}, 1
              FROM #{APP_CONFIG['cartodb_table']}
              WHERE ST_Intersects(#{geom_sql}, the_geom) AND status = 1 AND name = #{name});
        SQL
=end
        # Remove validated area from base
        sql = sql + <<-SQL
          UPDATE #{APP_CONFIG['cartodb_table']} SET the_geom=ST_Multi(ST_Union(ST_Difference(the_geom,#{geom_sql}), ST_GeomFromEWKT('SRID=4326;POLYGON EMPTY'))) WHERE ST_Intersects(the_geom, #{geom_sql}) AND status = #{Status::ORIGINAL} AND name = #{name};
        SQL
        puts "Hammer Add: #{sql}"
      when Actions::DELETE
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, name, status, action, email)
            (SELECT ST_Multi(ST_Intersection(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326))), #{name}, NULL, #{action}, '#{email}'
              FROM #{APP_CONFIG['cartodb_table']}
              WHERE ST_Intersects(the_geom, ST_GeomFromText('SRID=4326;POLYGON((#{polygon}))', 4326)) AND status IS NOT NULL AND name = #{name});
          UPDATE #{APP_CONFIG['cartodb_table']} SET the_geom=ST_Multi(ST_Union(ST_Difference(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326)), ST_GeomFromEWKT('SRID=4326;POLYGON EMPTY'))) WHERE ST_Intersects(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326)) AND name = #{name} AND status IS NOT NULL
        SQL
    end
    CartoDB::Connection.query sql
  rescue CartoDB::Client::Error
    errors.add :base, 'There was an error trying to render the layers.'
    puts "There was an error trying to execute the following query:\n#{sql}"
  end

  def self.get_from_cartodb layer_name, layer_status, email
    require 'net/http'
    require 'uri'
    #create folder if it doesn't exist
    base_path = "#{Rails.root}/tmp/exports/user_edits"
    if !File.exists?(base_path)
      FileUtils.mkdir_p base_path
    end
    files_path = base_path + "/files"
    if !File.exists?(files_path)
      FileUtils.mkdir_p files_path
    end
    zip_path = base_path + "/zip"
    if !File.exists?(zip_path)
      FileUtils.mkdir_p zip_path
    end
    zip_name = "/#{email ? email+"_" : ""}#{Status.key_for(layer_name).to_s}_#{Status.key_for(layer_status).to_s}.zip"
    email_query = layer_status != Status::USER_EDITS ? "" : ( email.present? ? sanitize_sql_array(["AND email like ?", email]) : "AND email IS NOT NULL" )
    name_query = sanitize_sql_array(["name = ?", layer_name])
    status_query = sanitize_sql_array(["status = ?", layer_status])
    query = "SELECT * FROM #{APP_CONFIG['cartodb_table']} WHERE #{name_query} AND #{status_query} #{email_query} LIMIT #{USER_EDITS_LIMIT}&format=geojson"
    url = URI.escape "http://carbon-tool.cartodb.com/api/v1/sql?q=#{query}"
    uri = URI.parse url
    res = Net::HTTP.get_response(uri)
    ogr_command = "ogr2ogr -overwrite -skipfailures -f 'ESRI Shapefile' #{files_path} '#{res.body}'"
    system ogr_command
    system "zip -j #{zip_path+zip_name} #{files_path}/*"
    zip_path+zip_name
  end
end
