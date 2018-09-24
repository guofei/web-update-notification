class CrawlerJsJob < ActiveJob::Base
  queue_as :default

  def perform(page_id, page_url, old_digest)
    # Do something later
  end
end
