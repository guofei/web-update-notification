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
#
# Indexes
#
#  index_users_on_channel  (channel) UNIQUE
#

class User < ActiveRecord::Base
  has_many :pages, primary_key: 'channel', foreign_key: 'push_channel'

  def updated_recently
    updated_at > 60.days.ago
  end
end
