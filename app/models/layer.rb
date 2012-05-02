class Layer < ActiveRecord::Base
  belongs_to :user

  validates :name, presence: true, inclusion: { in: Names.list, message: "%{value} is not a valid name" }
  validates :action, presence: true, inclusion: { in: Actions.list, message: "%{value} is not a valid action" }
  validates :polygon, presence: true
  validates :user, presence: true
  validates :knowledge, presence: true

  before_create :cartodb

  def cartodb
    geom_sql = "ST_GeomFromText('MULTIPOLYGON(((#{polygon})))', 4326)"
    # SQL CartoDB
    case self.action
      when Actions::VALIDATE
        # Insert validated area polygon
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, name, status, action, email)
            (SELECT ST_Multi(ST_Intersection(the_geom, #{geom_sql})), #{name}, #{Status::VALIDATED}, #{action}, '#{user.email}'
              FROM #{APP_CONFIG['cartodb_table']}
              WHERE ST_Intersects(the_geom, #{geom_sql}) AND status = #{Status::ORIGINAL} AND name = #{name});
        SQL

        # Remove validated area from base
        sql = sql + <<-SQL
          UPDATE #{APP_CONFIG['cartodb_table']} SET the_geom=ST_Multi(ST_Union(ST_Difference(the_geom,#{geom_sql}), ST_GeomFromEWKT('SRID=4326;POLYGON EMPTY'))) WHERE ST_Intersects(the_geom, #{geom_sql}) AND status = #{Status::ORIGINAL} AND name = #{name};
        SQL

      when Actions::ADD

        # Add the user geometry, minus existing validations (using ST_Difference if any polys intersect)
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, name, status, action, email) 
            SELECT
              ST_Multi(CASE WHEN existing_validations.the_geom IS NOT NULL THEN 
                ST_Difference(
                  #{geom_sql},
                  ST_Multi(existing_validations.the_geom))
              ELSE
                #{geom_sql}
              END)
              ,#{name}, #{Status::VALIDATED}, #{action}, '#{user.email}' FROM (
              SELECT ST_Union(the_geom) as the_geom
              FROM #{APP_CONFIG['cartodb_table']}
              WHERE ST_Intersects(#{geom_sql}, the_geom) AND status = #{Status::VALIDATED} AND name = #{name}
            ) as existing_validations;
        SQL

        # Remove validated area from base
        sql = sql + <<-SQL
          UPDATE #{APP_CONFIG['cartodb_table']} SET the_geom=ST_Multi(ST_Union(ST_Difference(the_geom,#{geom_sql}), ST_GeomFromEWKT('SRID=4326;POLYGON EMPTY'))) WHERE ST_Intersects(the_geom, #{geom_sql}) AND status = #{Status::ORIGINAL} AND name = #{name};
        SQL

      when Actions::DELETE
        # Insert deleted area
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, name, status, action, email)
            (SELECT ST_Multi(ST_Intersection(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326))), #{name}, NULL, #{action}, '#{user.email}'
              FROM #{APP_CONFIG['cartodb_table']}
              WHERE ST_Intersects(the_geom, ST_GeomFromText('SRID=4326;POLYGON((#{polygon}))', 4326)) AND status IS NOT NULL AND name = #{name});
        SQL

        # Remove all intersecting area
        sql = sql + <<-SQL
          UPDATE #{APP_CONFIG['cartodb_table']} SET the_geom=ST_Multi(ST_Union(ST_Difference(the_geom,#{geom_sql}), ST_GeomFromEWKT('SRID=4326;POLYGON EMPTY'))) WHERE ST_Intersects(the_geom, #{geom_sql}) AND status IS NOT NULL AND name = #{name};
        SQL
    end
    CartoDB::Connection.query sql
  rescue CartoDB::Client::Error
    errors.add :base, 'There was an error trying to render the layers.'
    puts "There was an error trying to execute the following query:\n#{sql}"
  end

  # Generates a shp file of user edits of the specified type to the specified layer
  #
  # @param [Integer] layer_name enum of the layer you want edits to
  # @param [Integer] layer_status enum of the status you want 
  # @param [User] user the user you want edits by
  # @return [String] Location of the shp file
  def self.get_from_cartodb layer_name, layer_status, user
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

    zip_name = "/#{user.email ? user.email+"_" : ""}#{Status.key_for(layer_name).to_s}_#{Status.key_for(layer_status).to_s}.zip"

    # Build the cartodb query
    email_query = layer_status != Status::USER_EDITS ? "" : ( user.email.present? ? sanitize_sql_array(["AND email = ?", user.email]) : "AND email IS NOT NULL" )
    name_query = sanitize_sql_array(["name = ?", layer_name])
    status_query = sanitize_sql_array(["status = ?", layer_status])
    query = "SELECT * FROM #{APP_CONFIG['cartodb_table']} WHERE #{name_query} AND #{status_query} #{email_query} LIMIT #{USER_EDITS_LIMIT}&format=geojson"

    # Get the data
    url = URI.escape "http://carbon-tool.cartodb.com/api/v1/sql?q=#{query}"
    uri = URI.parse url
    res = Net::HTTP.get_response(uri)

    logger.info url

    #Build the zip file
    ogr_command = "ogr2ogr -overwrite -skipfailures -f 'ESRI Shapefile' #{files_path} '#{res.body}'"
    system ogr_command
    system "zip -j #{zip_path+zip_name} #{files_path}/*"

    zip_path+zip_name
  end
end
