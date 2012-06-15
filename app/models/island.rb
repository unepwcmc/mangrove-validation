class Island < ActiveRecord::Base
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
end
