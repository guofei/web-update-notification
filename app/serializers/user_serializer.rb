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

class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :channel, :device_token, :device_type,
             :locale_identifier, :time_zone, :updated_at
end
