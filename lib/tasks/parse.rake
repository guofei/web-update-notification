require 'json'

namespace :parse do
  task migrate: :environment do
    json_file = "#{Rails.root}/public/seed_data/db.json"
    File.open(json_file) do |file|
      hash = JSON.load(file)
      hash['results'].each do |v|
        next if v['channels'].nil?
        uuid = v['channels'].first
        dToken = v['deviceToken']
        dType =  v['deviceType']
        li = v['localeIdentifier']
        tz = v['timeZone']
      end
    end
  end
end
