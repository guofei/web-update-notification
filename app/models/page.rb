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
    return if is_stop_fetch?
    FetchWebpageJob.set(wait: sec.seconds).perform_later(id)
  end

  def fetch
    return if stop_fetch
    uri = get_uri url
    return if uri.nil?

    new_content = get_content uri
    return nil if new_content.nil?

    new_digest = Digest::MD5.hexdigest(new_content)

    return if new_digest == digest

    self.content = new_content
    self.digest = new_digest
    save

    push_to_devise
  end

  private

  def alert_data
    {
      sound: 'default',
      alert: "#{url} has been updated"
    }
  end

  def push_to_devise
    return nil if push_channel.nil? || push_channel.length <= 0
    client = Parse.create application_id: Rails.application.secrets.parse_app_id,
                          api_key: Rails.application.secrets.parse_api_key
    push = client.push(alert_data, push_channel)
    push.save
  rescue
    nil
  end

  def is_stop_fetch?
    stop_fetch || sec.nil? || sec <= 0
  end

  # @param url URI or String
  # @return URI or nil
  def get_uri(url)
    uri = url.class == Addressable::URI ? url.normalize : Addressable::URI.parse(url).normalize
    return uri if uri.scheme == 'http' || uri.scheme == 'https'
    nil
  rescue
    nil
  end

  # @param url URI or String
  # @return String
  def get_content(url)
    doc = doc url
    return nil if doc.nil?

    body = doc.xpath('//body')
    if body.empty?
      doc.text
    else
      body.text
    end
  end

  # @param url URI or String
  # @return Nokogiri::HTML::Document
  def doc(url)
    uri = get_uri url
    return nil if uri.nil?

    file = open(uri, 'User-Agent' => 'Googlebot/2.1')
    doc = Nokogiri::HTML(file)
    file.close
    doc
  rescue
    file.close if file.class == Tempfile
    nil
  end
end
