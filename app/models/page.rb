# == Schema Information
#
# Table name: pages
#
#  id         :integer          not null, primary key
#  content    :text
#  hash       :string
#  uri        :string
#  uuid       :string
#  sec        :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_pages_on_uuid  (uuid) UNIQUE
#

class Page < ActiveRecord::Base
end
