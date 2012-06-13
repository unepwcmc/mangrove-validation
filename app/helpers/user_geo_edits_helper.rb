module UserGeoEditsHelper
  def get_location(id)
    "/exports/user_geo_edits/#{id}.zip"
  end
end
