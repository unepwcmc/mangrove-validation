class Layer < ActiveRecord::Base
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
        # Insert validated area polygon
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, name, status, action, email)
            (SELECT ST_Multi(ST_Intersection(the_geom, #{geom_sql})), #{name}, #{Status::VALIDATED}, #{action}, '#{email}'
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
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, name, status, email) 
            SELECT
              ST_Multi(CASE WHEN existing_validations.the_geom IS NOT NULL THEN 
                ST_Difference(
                  #{geom_sql},
                  ST_Multi(existing_validations.the_geom))
              ELSE
                #{geom_sql}
              END)
              ,#{name}, #{Status::VALIDATED}, '#{email}' FROM (
              SELECT ST_Union(the_geom) as the_geom
              FROM #{APP_CONFIG['cartodb_table']}
              WHERE ST_Intersects(#{geom_sql}, the_geom) AND status = #{Status::VALIDATED} AND name = #{name}
            ) as existing_validations;
        SQL

        # Remove validated area from base
        sql = sql + <<-SQL
          UPDATE #{APP_CONFIG['cartodb_table']} SET the_geom=ST_Multi(ST_Union(ST_Difference(the_geom,#{geom_sql}), ST_GeomFromEWKT('SRID=4326;POLYGON EMPTY'))) WHERE ST_Intersects(the_geom, #{geom_sql}) AND status = #{Status::ORIGINAL} AND name = #{name};
        SQL

        puts "Add query: #{sql}"

      when Actions::DELETE
        # Insert deleted area
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, name, status, action, email)
            (SELECT ST_Multi(ST_Intersection(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326))), #{name}, NULL, #{action}, '#{email}'
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

end
