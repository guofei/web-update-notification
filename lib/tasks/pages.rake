namespace :pages do
  desc 'fetch all pages'
  task fetch: :environment do
    Page.find_each do |page|
      unless page.stop_fetch
        p page.id
        page.update_content
      end
    end
  end
end
