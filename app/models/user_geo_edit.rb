class UserGeoEdit < ActiveRecord::Base
  belongs_to :user
  belongs_to :island
  belongs_to :reallocated_from_island, :class_name => 'Comment'

  validates :action, presence: true, inclusion: { in: %w(validate add delete reallocate) }
  validates :polygon, presence: true
  validates :user, presence: true
  validates :knowledge, presence: true

  before_create :cartodb
  def cartodb
    geom_sql = "ST_GeomFromText('MULTIPOLYGON(((#{polygon})))', 4326)"
    # SQL CartoDB
    case self.action
      when 'validate'
        # Insert validated area polygon
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']}
            (the_geom, id_gid, status, action, email, institution, user_name, iso3, name, name_local, created_at, updated_at)
          (SELECT ST_Multi(ST_Intersection(the_geom, #{geom_sql})),
            #{island_id}, 'validated', '#{action}', '#{user.email}', '#{user.institution}', '#{user.name}', '#{h(island.iso_3)}', '#{h(island.name)}', '#{h(island.name_local)}', '#{island.created_at}', '#{island.updated_at}'
           FROM #{APP_CONFIG['cartodb_table']}
           WHERE ST_Intersects(the_geom, #{geom_sql})
             AND status = 'original'
             AND id_gid = #{island_id});
        SQL

        # Remove validated area from base
        sql = sql + <<-SQL
          UPDATE #{APP_CONFIG['cartodb_table']} SET the_geom=ST_Multi(ST_Union(ST_Difference(the_geom,#{geom_sql}), ST_GeomFromEWKT('SRID=4326;POLYGON EMPTY'))) WHERE ST_Intersects(the_geom, #{geom_sql}) AND status = 'original' AND id_gid = #{island_id};
        SQL

      when 'add'
        #time_in_milliseconds = (Time.now.to_f * 1000.0).round

        # Add the user geometry, minus existing validations (using ST_Difference if any polys intersect)
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']}
            (the_geom, id_gid, status, action, email, institution, user_name, country, iso3, name, name_local, created_at, updated_at) 
          SELECT
            ST_Multi(
              CASE WHEN existing_validations.the_geom IS NOT NULL THEN 
                ST_Difference(
                  #{geom_sql},
                  ST_Multi(existing_validations.the_geom))
              ELSE
                #{geom_sql}
              END
            ),
            #{island_id}, 'validated', '#{action}', '#{user.email}', '#{user.institution}', '#{user.name}', '#{h(island.country)}', '#{h(island.iso_3)}', '#{h(island.name)}', '#{h(island.name_local)}', '#{island.created_at}', '#{island.updated_at}'
          FROM (
            SELECT ST_Union(the_geom) as the_geom
            FROM #{APP_CONFIG['cartodb_table']}
            WHERE ST_Intersects(#{geom_sql}, the_geom)
              AND status = 'validated'
              AND id_gid = #{island_id}
          ) as existing_validations;
        SQL

        # Remove validated area from base
        sql = sql + <<-SQL
          UPDATE #{APP_CONFIG['cartodb_table']} SET the_geom=ST_Multi(ST_Union(ST_Difference(the_geom,#{geom_sql}), ST_GeomFromEWKT('SRID=4326;POLYGON EMPTY'))) WHERE ST_Intersects(the_geom, #{geom_sql}) AND status = 'original' AND id_gid = #{island_id};
        SQL

      when 'delete'
        # Insert deleted area
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']}
            (the_geom, id_gid, status, action, email, institution, user_name, country, iso3, name, name_local, created_at, updated_at)
          (SELECT
            ST_Multi(
              ST_Intersection(
                the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326))
            ),
            #{island_id}, NULL, '#{action}', '#{user.email}', '#{user.institution}', '#{user.name}', '#{h(island.country)}', '#{h(island.iso_3)}', '#{h(island.name)}', '#{h(island.name_local)}', '#{island.created_at}', '#{island.updated_at}'
          FROM #{APP_CONFIG['cartodb_table']}
          WHERE ST_Intersects(the_geom, ST_GeomFromText('SRID=4326;POLYGON((#{polygon}))', 4326))
            AND status IS NOT NULL
            AND id_gid = #{island_id}
          );
        SQL

        # Remove all intersecting area
        sql = sql + <<-SQL
          UPDATE #{APP_CONFIG['cartodb_table']} SET the_geom=ST_Multi(ST_Union(ST_Difference(the_geom,#{geom_sql}), ST_GeomFromEWKT('SRID=4326;POLYGON EMPTY'))) WHERE ST_Intersects(the_geom, #{geom_sql}) AND status IS NOT NULL AND id_gid = #{island_id};
        SQL
    end
    CartoDB::Connection.query sql
  rescue CartoDB::Client::Error
    errors.add :base, 'There was an error trying to render the map.'
    logger.info "There was an error trying to execute the following query:\n#{sql}"
  end
end
