require 'faraday'
require 'digest/md5'

# Crawl webpage and emit to controller
class CrawlerJob < ActiveJob::Base
  include Crawlable
  queue_as :default

  def perform(page_id, page_url, old_digest)
    new_title, new_content = crawl(page_url)
    param = get_params(new_title, new_content, old_digest)
    post(crawled_api_url(page_id), param)
  rescue OpenURI::HTTPError => e
    # TODO set error code
    post(crawled_api_url(page_id), error: true, message: e.message)
  end

  private

  def post(url, param)
    client = Faraday.new(url: url)
    client.post do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = param.to_json
    end
  end

  def get_params(new_title, new_content, old_digest)
    return { continue: true } if new_content.nil?
    new_digest = Digest::MD5.hexdigest(new_content)
    return { continue: true } if new_digest == old_digest
    {
      page: { title: new_title, content: new_content, digest: new_digest },
      changed: true,
      continue: true
    }
  end

  def crawled_api_url(id)
    host = Rails.application.secrets.api_host
    "#{host}/pages/#{id}/crawled"
  end
end
