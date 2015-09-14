# == Schema Information
#
# Table name: pages
#
#  id           :integer          not null, primary key
#  content      :text
#  digest       :string
#  uri          :string
#  sec          :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  push_channel :string
#

class Page < ActiveRecord::Base
  after_create do |page|
    FetchWebpageJob.set(wait: page.sec.seconds).perform_later(page.id)
  end
end
