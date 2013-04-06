CARTODB_CONFIG = YAML.load_file(Rails.root.join('config/cartodb_config.yml'))
CartoDB::Init.start CARTODB_CONFIG
