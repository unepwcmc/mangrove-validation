class Layer < ActiveRecord::Base
  NAMES = %w(mangrove coral)
  ACTIONS = %w(validate add delete)

  validates :name, presence: true, inclusion: { in: NAMES, message: "%{value} is not a valid name" }
  validates :action, presence: true, inclusion: { in: ACTIONS, message: "%{value} is not a valid action" }
  validates :polygon, presence: true
  validates :email, presence: true, format: {with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }

  before_create :cartodb

  def cartodb
    geom_sql = "ST_GeomFromText('MULTIPOLYGON(((#{polygon})))', 4326)"
    # SQL CartoDB
    case self.action
      when 'validate'
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, name, status)
            (SELECT ST_Multi(ST_Intersection(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326))), #{NAMES.index(name)}, 1
              FROM #{APP_CONFIG['cartodb_table']}
              WHERE ST_Intersects(the_geom, ST_GeomFromText('SRID=4326;POLYGON((#{polygon}))', 4326)) AND status = 0 AND name = #{NAMES.index(name)});
          UPDATE #{APP_CONFIG['cartodb_table']} SET the_geom=ST_Multi(ST_Union(ST_Difference(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326)), ST_GeomFromEWKT('SRID=4326;POLYGON EMPTY'))) WHERE ST_Intersects(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326)) AND name = #{NAMES.index(name)} AND status = 0
        SQL
      when 'add'
        # Add with a hammer
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, name, status) VALUES
            (#{geom_sql}, #{NAMES.index(name)}, 1);
        SQL
=begin
# This way should work, but we're having some carto db issues, revisit
        # Add the difference
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, name, status)
            (SELECT ST_Multi((ST_Difference(#{geom_sql}, the_geom))), #{NAMES.index(name)}, 1
              FROM #{APP_CONFIG['cartodb_table']}
              WHERE ST_Intersects(#{geom_sql}, the_geom) AND status = 1 AND name = #{NAMES.index(name)});
        SQL
        # Add the intersection
        sql = sql + <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, name, status)
            (SELECT ST_Multi((ST_Intersection(#{geom_sql}, the_geom))), #{NAMES.index(name)}, 1
              FROM #{APP_CONFIG['cartodb_table']}
              WHERE ST_Intersects(#{geom_sql}, the_geom) AND status = 1 AND name = #{NAMES.index(name)});
        SQL
=end
        # Remove validated area from base
        sql = sql + <<-SQL
          UPDATE #{APP_CONFIG['cartodb_table']} SET the_geom=ST_Multi(ST_Union(ST_Difference(the_geom,#{geom_sql}), ST_GeomFromEWKT('SRID=4326;POLYGON EMPTY'))) WHERE ST_Intersects(the_geom, #{geom_sql}) AND status = 0 AND name = #{NAMES.index(name)};
        SQL
        puts "Hammer Add: #{sql}"
      when 'delete'
        sql = <<-SQL
          UPDATE #{APP_CONFIG['cartodb_table']} SET the_geom=ST_Multi(ST_Union(ST_Difference(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326)), ST_GeomFromEWKT('SRID=4326;POLYGON EMPTY'))) WHERE ST_Intersects(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326)) AND name = #{NAMES.index(name)}
        SQL
    end
    CartoDB::Connection.query sql
  rescue CartoDB::Client::Error
    errors.add :base, 'There was an error trying to render the layers.'
    puts "There was an error trying to execute the following query:\n#{sql}"
  end

  def self.user_edits_csv
    CSV.generate do |csv|
      csv << ["Email", "Action", "Polygon", "Date"]
      Layer.order("created_at").each do |l|
        csv << [l.email, l.action, l.polygon, l.created_at.strftime("%d/%b/%Y")]
      end
    end
  end
end
