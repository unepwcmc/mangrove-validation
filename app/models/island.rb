class Island < ActiveRecord::Base
  validates :name, presence: true
  validates :name_local, presence: true
  validates :iso_3, presence: true
  validates :source, presence: true

  def self.filter(params)
    result = self.scoped

    # If the query is a number, search for the ID instead
    # This could be done with query.to_i.to_a?(Numeric) which seems more robust
    # but this would result in things like "3a" -> "3" which is not ideal.
    if (params[:query] =~ /^[0-9]+$/).nil?
      result = result.where("name ILIKE '%#{params[:query]}%'")
    else
      result = result.where(id: params[:query].to_i)
    end

    result
  end

  before_destroy :delete_from_cartodb
  def delete_from_cartodb
    sql = <<-SQL
          DELETE FROM #{APP_CONFIG['cartodb_table']}
          WHERE island_id = '#{self.id}'
          SQL
    CartoDB::Connection.query sql
  rescue CartoDB::Client::Error
    errors.add :base, 'There was an error trying to render the map.'
    logger.info "There was an error trying to execute the following query:\n#{sql}"
  end
end
