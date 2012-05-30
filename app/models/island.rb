class Island < ActiveRecord::Base
  def self.filter(params)
    result = self.scoped
    result = result.where("name ILIKE '%#{params[:query]}%'") if params.symbolize_keys.include?(:query)
    result = result.where(id: params[:id]) if params.symbolize_keys.include?(:id)
    result
  end
end
