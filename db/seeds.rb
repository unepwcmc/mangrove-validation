# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

LayerDownload.create(name: 'Mangroves community layer (.shp)', layer: Names::MANGROVE, status: Status::VALIDATED)
LayerDownload.create(name: 'Corals community layer (.shp)', layer: Names::CORAL, status: Status::VALIDATED)
LayerDownload.create(name: 'Mangroves user edits (.shp)', layer: Names::MANGROVE, status: Status::USER_EDITS)
LayerDownload.create(name: 'Corals user edits (.shp)', layer: Names::CORAL, status: Status::USER_EDITS)
