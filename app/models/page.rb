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
#  title        :string
#  enable_js    :boolean          default(FALSE)
#

require 'json'
require 'digest/md5'
require 'csv'

# Page Info
class Page < ActiveRecord::Base
  include Crawlable

  belongs_to :user, primary_key: 'channel', foreign_key: 'push_channel'

  def self.to_csv
    CSV.generate do |csv|
      all.each do |page|
        csv << [page.id, page.url, page.title, page.sec, page.second,
                page.push_channel, page.stop_fetch, page.created_at,
                page.updated_at]
      end
    end
  end

  after_create :set_next_job
  before_update :set_next_job, if: :stop_fetch_changed?

  def set_next_job
    return if stop_fetch?
    CrawlerJob.set(wait: second.seconds).perform_later(id, url, digest)
  end

  def push_to_device
    return if stop_fetch?
    user.push_to_device(alert_data)
  rescue
    nil
  end

  def push_error_to_device(message)
    return if stop_fetch?
    user.push_to_device(alert_error_data(message))
  rescue
    nil
  end

  def second
    [min_check_time, sec].max
  end

  def fetch_without_push
    return if stop_fetch?
    new_title, new_content = crawl(url)
    update_content(new_title, new_content)
  end

  def fetch
    return if stop_fetch
    if content.blank?
      new_title, new_content = crawl(url)
      update_content(new_title, new_content)
    else
      # update content and push to device
      new_title, new_content = crawl(url)
      push_to_device if update_content(new_title, new_content)
    end
  end

  private

  def update_content(new_title, new_content)
    return false if new_content.nil?

    new_digest = Digest::MD5.hexdigest(new_content)
    return false if new_digest == digest

    new_diff = diff new_content
    self.content_diff = new_diff if new_diff
    self.digest = new_digest
    self.content = new_content
    self.title = new_title if new_title
    save

    true
  end

  def alert_data
    message = "#{url} has been updated"
    apns_data = {
      aps: {
        'sound': 'default',
        'alert': message,
        'content-available': 1,
        'url': url
      }
    }
    { default: message, APNS: apns_data.to_json }.to_json
  end

  def alert_error_data(err_msg)
    message = "Error: #{err_msg} #{url}"
    apns_data = {
      aps: {
        'sound': 'default',
        'alert': message,
        'content-available': 1,
        'url': url
      }
    }
    { default: message, APNS: apns_data.to_json }.to_json
  end

  def diff(new_content)
    return nil if new_content.nil? || content.nil?
    Diffy::Diff.new(content, new_content, context: 1).to_s(:text)
  end

  def update_ago?(time_ago)
    time_ago > updated_at
  end

  def created_ago?(time_ago)
    time_ago > created_at
  end

  def min_check_time
    if sec < 20.minutes.seconds
      if !created_ago?(2.days.ago)
        sec
      elsif update_ago?(3.days.ago)
        [last_check_time, 1.hours.seconds].min
      else
        [last_check_time, 20.minutes.seconds].min
      end
    elsif sec < 2.hours.seconds
      if update_ago?(3.days.ago)
        [last_check_time, 6.hours.seconds].min
      else
        [last_check_time, 1.hours.seconds].min
      end
    elsif sec < 1.days.seconds
      if update_ago?(3.days.ago)
        [last_check_time, 2.days.seconds].min
      else
        [last_check_time, 1.days.seconds].min
      end
    else
      [last_check_time, 3.days.seconds].min
    end
  end

  def last_check_time
    (Time.zone.now - updated_at).to_i
  end

  def stop_fetch?
    return true if stop_fetch || sec.nil? || sec <= 0

    if user && user.enabled
      return false
    else
      return true
    end
  end
end
