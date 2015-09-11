# == Schema Information
#
# Table name: pages
#
#  id           :integer          not null, primary key
#  content      :text
#  hash         :string
#  uri          :string
#  sec          :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  push_channel :string
#

class Page < ActiveRecord::Base
end
