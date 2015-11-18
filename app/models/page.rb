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

require 'digest/md5'

class Page < ActiveRecord::Base
  include Crawlable

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
    return nil if sec.nil?

    half_one_hour = 30 * 60
    if sec < half_one_hour
      half_one_hour
    else
      sec
    end
  end

  def fetch
    return if stop_fetch
    push_to_devise if update_content
  end

  private

  def update_content
    new_content = crawl
    return false if new_content.nil?

    new_digest = Digest::MD5.hexdigest(new_content)
    return false if new_digest == digest

    new_diff = diff new_content
    self.content_diff = new_diff if new_diff
    self.digest = new_digest
    self.content = new_content
    save

    true
  end

  def alert_data
    {
      sound: 'default',
      url: url,
      alert: "#{url} has been updated"
    }
  end

  def diff(new_content)
    return nil if new_content.nil? || content.nil?
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
end
