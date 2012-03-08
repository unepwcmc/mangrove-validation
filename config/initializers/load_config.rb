APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env].merge YAML.load_file("#{Rails.root}/config/http_auth_config.yml")[Rails.env]
