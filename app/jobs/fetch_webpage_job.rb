require 'open-uri'
require 'digest/md5'
require 'addressable/uri'

class FetchWebpageJob < ActiveJob::Base
  queue_as :default

  after_perform do |job|
    page = Page.find job.arguments.first
    FetchWebpageJob.set(wait: page.sec.seconds).perform_later(page.id)
  end

  def perform(page_id)
    page = Page.find(page_id)
    uri = get_uri page.url
    return if uri.nil?

    open(uri, 'User-Agent' => 'Googlebot/2.1') do |f|
      content = f.read
      digest = Digest::MD5.hexdigest(content)

      if digest != page.digest
        page.content = content
        page.digest = digest
        page.save

        # TODO push
      end
    end
  end

  private

  # @param url URI or String
  # @return URI or nil
  def get_uri(url)
    uri = url.class == Addressable::URI ? url.normalize : Addressable::URI.parse(url).normalize
    return uri if uri.scheme == 'http' || uri.scheme == 'https'
    nil
  rescue
    nil
  end
end
