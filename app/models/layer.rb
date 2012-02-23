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
        CartoDB::Connection.insert_row APP_CONFIG['cartodb_table'], the_geom: "ST_GeomFromTEXT('MULTIPOLYGON(((#{polygon})))', 4326)", name: NAMES.index(name), status: 1
      when 'delete'
        sql = <<-SQL
        SQL
      when 'validate'
    end
  end
end
