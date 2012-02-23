class Layer < ActiveRecord::Base

  NAMES = ['mangrove', 'coral']
  ACTIONS = ['validate', 'add', 'delete']
  validates :name, presence: true, inclusion: { in: NAMES, message: "%{value} is not a valid name" }
  validates :action, presence: true, inclusion: { in: ACTIONS, message: "%{value} is not a valid action" }
  validates :polygon, presence: true

  before_create do
    # SQL CartoDB
    case self.action
      when 'add'
        sql = <<-SQL
             INSERT INTO #{APP_CONFIG['cartodb_table']} (the_geom, name, status)
             VALUES (ST_GeomFromText('MULTIPOLYGON(((#{self.polygon})))', 4326), #{NAMES.index(self.name)}, 1)
        SQL
      when 'delete'
      when 'validate'
    end
    CartoDB::Connection.query sql
  end
end
