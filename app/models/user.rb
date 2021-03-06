# == Schema Information
#
# Table name: users
#
#  id                :integer          not null, primary key
#  name              :string
#  channel           :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  device_token      :string
#  device_type       :string
#  locale_identifier :string
#  time_zone         :string
#  endpoint_arn      :string
#  enabled           :boolean          default(TRUE)
#
# Indexes
#
#  index_users_on_channel  (channel) UNIQUE
#

class User < ActiveRecord::Base
  include Pushable
  has_many :pages, primary_key: 'channel', foreign_key: 'push_channel'

  def updated_recently
    updated_at > 60.days.ago
  end

  private

  def enable
    return if enabled
    self.enabled = true
    save
    pages.each do |pg|
      pg.set_next_job unless pg.stop_fetch
    end
  end

  def disable
    self.enabled = false
    save
  end
end
