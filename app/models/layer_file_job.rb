class LayerFileJob
  include Resque::Plugins::Status

  def perform
    layer_file = LayerFile.new(options['cartodb_table'], options['layer_name'], options['layer_status'], options['email'])
    status['filename'] = layer_file.generate
  end

end