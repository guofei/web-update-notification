class CrawlerJob < ActiveJob::Base
  include Crawlable
  queue_as :default

  def perform(*args)
    # Do something later
  end
end
