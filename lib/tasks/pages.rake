require 'csv'

namespace :pages do
  desc 'fetch all pages'
  task fetch: :environment do
    Page.find_each do |page|
      if page.fetch_without_push
        p page.id
        puts page.title
      end
    end
  end

  task to_csv: :environment do
    file = Rails.root.join('tmp', 'pages.csv')
    CSV.open(file, 'wb') do |csv|
      Page.find_each do |page|
        csv << [page.id, page.url, page.title, page.sec, page.second,
                page.push_channel, page.stop_fetch, page.created_at,
                page.updated_at]
      end
    end
  end

  task stop_fetch_for_null_title: :environment do
    Page.find_each do |page|
      if page.title.nil?
        p page.id
        page.stop_fetch = true
        page.save
      end
    end
  end

  task clean_content: :environment do
    Page.find_each do |page|
      next if page.content.nil?
      page.content = nil
      page.save
    end
  end

  task reset_check_time: :environment do
    Page.find_each do |page|
      if page.sec == 3 * 60 * 60
        p page.id
        page.sec = 4 * 60 * 60
        page.save
      end
    end
  end
end
