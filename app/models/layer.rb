class Layer < ActiveRecord::Base
  NAMES = %w(mangrove coral)
  ACTIONS = %w(validate add delete)

  validates :name, presence: true, inclusion: { in: NAMES, message: "%{value} is not a valid name" }
  validates :action, presence: true, inclusion: { in: ACTIONS, message: "%{value} is not a valid action" }
  validates :polygon, presence: true
  validates :email, format: {with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/, message: "is invalid" }

  before_create :cartodb

  def cartodb
    # SQL CartoDB
    case self.action
      when 'validate'
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, name, status)
          (SELECT ST_Multi(ST_Intersection(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326))), #{NAMES.index(name)}, 1 FROM #{APP_CONFIG['cartodb_table']} WHERE ST_Intersects(the_geom, ST_GeomFromText('SRID=4326;POLYGON((#{polygon}))', 4326)))
        SQL
      when 'add'
        sql = <<-SQL
          INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, name, status)
          VALUES (ST_GeomFromText('MULTIPOLYGON(((#{polygon})))', 4326), #{NAMES.index(name)}, 1);
          UPDATE #{APP_CONFIG['cartodb_table']} SET the_geom=ST_Multi(ST_Union(ST_Difference(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326)), ST_GeomFromEWKT('SRID=4326;POLYGON EMPTY'))) WHERE ST_Intersects(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326)) AND status = 0 AND name = #{NAMES.index(name)};
        SQL
      when 'delete'
        sql = <<-SQL
          UPDATE #{APP_CONFIG['cartodb_table']} SET the_geom=ST_Multi(ST_Union(ST_Difference(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326)), ST_GeomFromEWKT('SRID=4326;POLYGON EMPTY'))) WHERE ST_Intersects(the_geom, ST_GeomFromText('POLYGON((#{polygon}))', 4326)) AND name = #{NAMES.index(name)}
        SQL
    end
    CartoDB::Connection.query sql
  rescue CartoDB::Client::Error
    errors.add :base, 'There was an error trying to render the layers.'
  end
end
