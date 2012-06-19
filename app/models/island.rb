class Island < ActiveRecord::Base
  belongs_to :country, :foreign_key => :iso_3, :primary_key => :iso_3

  def self.filter(params)
    result = self.scoped
    result = result.where("name ILIKE '%#{params[:query]}%'") if params.symbolize_keys.include?(:query)
    result = result.where(id: params[:id]) if params.symbolize_keys.include?(:id)
    result
  end

  # Make json return the proper country name
  def as_json(options={})
    {
      :name => name,
      :name_local => name_local,
      :country => country.try(:name)
    }
  end
end
