module UserGeoEditsHelper
  def get_location(id)
    "exports/user_geo_edit/#{id}.zip"
  end
end
