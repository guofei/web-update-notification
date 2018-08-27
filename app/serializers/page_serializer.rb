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

class PageSerializer < ActiveModel::Serializer
  attributes :id, :url, :title, :sec, :updated_at, :push_channel, :stop_fetch, :content_diff
end
