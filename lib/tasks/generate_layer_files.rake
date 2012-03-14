namespace :generate_layer_files do
  desc 'Generate community layer files for download'
  task :all => [:"generate_layer_files:mangrove", :"generate_layer_files:coral"] do
  end
  desc 'Generate mangrove community layer files for download'
  task :mangrove => :environment do
    LayerFile.new(APP_CONFIG['cartodb_table'], Names::MANGROVE, Status::VALIDATED).generate
  end
  desc 'Generate coral community layer files for download'
  task :coral => :environment do
    LayerFile.new(APP_CONFIG['cartodb_table'], Names::CORAL, Status::VALIDATED).generate
  end
end
