class Island < ActiveRecord::Base
  def self.filter(params)
    if (params.symbolize_keys.keys & [:query]).empty?
      all
    else
      where("name ILIKE '%#{params[:query]}%'")
    end
  end
end
