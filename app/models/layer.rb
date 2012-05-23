class Layer < ActiveRecord::Base
  belongs_to :user

  validates :action, presence: true, inclusion: { in: %w(validate add delete) }
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
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, layer_id, status, action, email)
            (SELECT ST_Multi(ST_Intersection(the_geom, #{geom_sql})), #{id}, 'validated', #{action}, '#{user.email}'
              FROM #{APP_CONFIG['cartodb_table']}
              WHERE ST_Intersects(the_geom, #{geom_sql}) AND status = 'original' AND layer_id = #{id});
        SQL

        # Remove validated area from base
        sql = sql + <<-SQL
          UPDATE #{APP_CONFIG['cartodb_table']} SET the_geom=ST_Multi(ST_Union(ST_Difference(the_geom,#{geom_sql}), ST_GeomFromEWKT('SRID=4326;POLYGON EMPTY'))) WHERE ST_Intersects(the_geom, #{geom_sql}) AND status = 'original' AND layer_id = #{id};
        SQL

      when Actions::ADD

        # Add the user geometry, minus existing validations (using ST_Difference if any polys intersect)
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, layer_id, status, action, email) 
            SELECT
              ST_Multi(CASE WHEN existing_validations.the_geom IS NOT NULL THEN 
                ST_Difference(
                  #{geom_sql},
                  ST_Multi(existing_validations.the_geom))
              ELSE
                #{geom_sql}
              END)
              ,#{id}, 'validated', #{action}, '#{user.email}' FROM (
              SELECT ST_Union(the_geom) as the_geom
              FROM #{APP_CONFIG['cartodb_table']}
              WHERE ST_Intersects(#{geom_sql}, the_geom) AND status = 'validated' AND layer_id = #{id}
            ) as existing_validations;
        SQL

        # Remove validated area from base
        sql = sql + <<-SQL
          UPDATE #{APP_CONFIG['cartodb_table']} SET the_geom=ST_Multi(ST_Union(ST_Difference(the_geom,#{geom_sql}), ST_GeomFromEWKT('SRID=4326;POLYGON EMPTY'))) WHERE ST_Intersects(the_geom, #{geom_sql}) AND status = 'original' AND layer_id = #{id};
        SQL

      when Actions::DELETE
        # Insert deleted area
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, layer_id, status, action, email)
            (SELECT ST_Multi(ST_Intersection(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326))), #{id}, NULL, #{action}, '#{user.email}'
              FROM #{APP_CONFIG['cartodb_table']}
              WHERE ST_Intersects(the_geom, ST_GeomFromText('SRID=4326;POLYGON((#{polygon}))', 4326)) AND status IS NOT NULL AND layer_id = #{id});
        SQL

        # Remove all intersecting area
        sql = sql + <<-SQL
          UPDATE #{APP_CONFIG['cartodb_table']} SET the_geom=ST_Multi(ST_Union(ST_Difference(the_geom,#{geom_sql}), ST_GeomFromEWKT('SRID=4326;POLYGON EMPTY'))) WHERE ST_Intersects(the_geom, #{geom_sql}) AND status IS NOT NULL AND layer_id = #{id};
        SQL
    end
    CartoDB::Connection.query sql
  rescue CartoDB::Client::Error
    errors.add :base, 'There was an error trying to render the layers.'
    logger.info "There was an error trying to execute the following query:\n#{sql}"
  end
end
