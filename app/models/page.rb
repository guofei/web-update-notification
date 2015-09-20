# == Schema Information
#
# Table name: pages
#
#  id           :integer          not null, primary key
#  content      :text
#  digest       :string
#  url          :string
#  sec          :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  push_channel :string
#  stop_fetch   :boolean          default(FALSE)
#

require 'open-uri'
require 'digest/md5'
require 'addressable/uri'

class Page < ActiveRecord::Base
  after_create do |page|
    page.fetch_in_job
  end

  before_update if: :stop_fetch_changed? do |page|
    page.fetch_in_job
  end

  def fetch_in_job
    return if stop_fetch
    FetchWebpageJob.set(wait: sec.seconds).perform_later(id)
  end

  def fetch
    return if stop_fetch
    uri = get_uri url
    return if uri.nil?

    open(uri, 'User-Agent' => 'Googlebot/2.1') do |f|
      new_content = f.read
      new_digest = Digest::MD5.hexdigest(new_content)

      if new_digest != digest
        self.content = new_content
        self.digest = new_digest
        save

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
