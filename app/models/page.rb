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
#  content_diff :text
#

require 'open-uri'
require 'tempfile'
require 'digest/md5'
require 'addressable/uri'

class Page < ActiveRecord::Base
  belongs_to :user, primary_key: 'channel', foreign_key: 'push_channel'

  after_create do |page|
    page.fetch_in_job
  end

  before_update if: :stop_fetch_changed? do |page|
    page.fetch_in_job
  end

  class << self
    def update_content
      find_each do |page|
        page.update_content if !page.stop_fetch
      end
    end
  end

  def fetch_in_job
    return if is_stop_fetch?
    FetchWebpageJob.set(wait: second.seconds).perform_later(id)
  end

  def second
    return nl if sec.nil?

    half_one_hour = 30 * 60
    if sec < half_one_hour
      half_one_hour
    else
      sec
    end
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

  def update_content
    uri = get_uri url
    return if uri.nil?
    new_content = get_content uri
    return nil if new_content.nil?
    new_digest = Digest::MD5.hexdigest(new_content)
    self.content_diff = diff new_content
    self.content = new_content
    self.digest = new_digest
    save
  end

  private

  def alert_data
    {
      sound: 'default',
      url: url,
      alert: "#{url} has been updated"
    }
  end

  def diff(new_content)
    return '' if new_content.nil? || content.nil?
    Diffy::Diff.new(new_content, content).to_s(:text)
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
    return true if stop_fetch || sec.nil? || sec <= 0

    if user && user.updated_recently
      return false
    else
      return true
    end
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

    doc.search('script').each do |script|
      script.content = ''
    end
    doc.text
  end

  # @param url URI or String
  # @return Nokogiri::HTML::Document
  def doc(url)
    uri = get_uri url
    return nil if uri.nil?

    file = open(uri, 'User-Agent' => 'Googlebot/2.1')
    doc = Nokogiri::HTML(file, &:noblanks)
    file.close
    doc
  rescue
    file.close if file.class == Tempfile
    nil
  end
end
