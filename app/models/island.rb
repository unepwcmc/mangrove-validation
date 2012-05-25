class Island < ActiveRecord::Base
  def self.filter(params)
    if (params.symbolize_keys.keys & [:id, :query]).empty?
      all
    else
      clause = {}
      clause[:id] = params[:id] if params[:id]
      clause[:query] = params[:query] if params[:query]

      where(clause)
    end
  end
end
