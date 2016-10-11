namespace :jobs do
  task init: :environment do
    Page.find_each(&:set_next_job)
  end
end
