namespace :jobs do
  task restart: :environment do
    Page.find_each(&:set_next_job)
  end
end
