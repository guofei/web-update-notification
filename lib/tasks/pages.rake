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
