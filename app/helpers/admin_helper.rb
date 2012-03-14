module AdminHelper
  def layer_download_link(layer_file)
    link_to 'Download',
      'http://' + APP_CONFIG['background_machine'] + admin_download_from_cartodb_path(:status => layer_file.layer_status, :name => layer_file.layer_name)
  end
  def layer_generate_link(layer_file)
    link_to 'Generate',
      'http://' + APP_CONFIG['background_machine'] + admin_generate_from_cartodb_path(:status => layer_file.layer_status, :name => layer_file.layer_name)
  end
end
