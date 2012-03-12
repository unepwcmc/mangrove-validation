namespace :generate_layer_files do
  desc 'Generate community layer files for download'
  task :all => [:"generate_layer_files:mangrove", :"generate_layer_files:coral"] do
  end
  desc 'Generate mangrove community layer files for download'
  task :mangrove => :environment do
    Layer.get_from_cartodb(0, 1, nil)
  end
  desc 'Generate coral community layer files for download'
  task :coral => :environment do
    Layer.get_from_cartodb(1, 1, nil)
  end
end
