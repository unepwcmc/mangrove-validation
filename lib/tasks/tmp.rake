namespace :tmp do
  namespace :exports do
    desc "Clear out export tmp files"
    task :clear => :environment do
      rm_tmp_cmd  = "rm -r #{Rails.root}/tmp/exports/user_geo_edit/*"
      rm_json_cmd = "rm -r #{Rails.root}/tmp/download*.json"

      system(rm_tmp_cmd)
      system(rm_json_cmd)
    end
  end
end
