require 'json'

namespace :parse do
  task migrate: :environment do
    json_file = "#{Rails.root}/public/seed_data/db.json"
    File.open(json_file) do |file|
      hash = JSON.load(file)
      hash['results'].each do |v|
        next if v['channels'].nil?
        uuid = v['channels'].first
        token = v['deviceToken']
        type =  v['deviceType']
        li = v['localeIdentifier']
        tz = v['timeZone']
        user = User.find_by(channel: uuid)
        next if user.nil?
        user.device_token = token
        user.device_type = type
        user.locale_identifier = li
        user.time_zone = tz
        user.save
      end
    end
  end

  task regist: :environment do
    User.find_each do |user|
      user.regist
    end
  end
end
