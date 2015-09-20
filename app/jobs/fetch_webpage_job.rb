class FetchWebpageJob < ActiveJob::Base
  queue_as :default

  after_perform do |job|
    page = Page.find_by_id(job.arguments.first)
    return if page.nil?
    page.fetch_in_job
  end

  def perform(page_id)
    page = Page.find_by_id(page_id)
    return if page.nil?
    page.fetch
  end
end
