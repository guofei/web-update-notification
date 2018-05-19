require 'faraday'
require 'digest/md5'

# Crawl webpage and emit to controller
class CrawlerJob < ActiveJob::Base
  include Crawlable
  queue_as :default

  def perform(page_id, page_url, old_digest)
    new_title, new_content = crawl(page_url)
    param = get_params(new_title, new_content, old_digest)
    Faraday.post crawled_api(page_id), param
  end

  private

  def get_params(new_title, new_content, old_digest)
    return if new_content.nil?
    new_digest = Digest::MD5.hexdigest(new_content)
    return if new_digest == old_digest
    {
      page: { title: new_title, content: new_content, digest: new_digest },
      changed: true
    }
  end

  def crawled_api(id)
    host = Rails.application.secrets.crawler_api_host
    "#{host}/pages/#{id}/crawled"
  end
end
