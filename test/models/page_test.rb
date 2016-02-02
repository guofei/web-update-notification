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
#

require 'test_helper'

class PageTest < ActiveSupport::TestCase
  test 'sec 60s, updated at 4 minutes ago' do
    page = Page.new(sec: 60, updated_at: 4.minutes.ago)
    assert_equal(3.minutes.seconds, page.second)
  end

  test 'sec 60s, updated at 10 minutes ago' do
    page = Page.new(sec: 60, updated_at: 10.minutes.ago)
    assert_equal(15.minutes.seconds, page.second)
  end

  test 'sec 60s, updated at 20 minutes ago' do
    page = Page.new(sec: 60, updated_at: 20.minutes.ago)
    assert_equal(15.minutes.seconds, page.second)
  end

  test 'sec 4hour, updated at 20 minutes ago' do
    page = Page.new(sec: 4.hours.seconds, updated_at: 20.minutes.ago)
    assert_equal(4.hours.seconds, page.second)
  end

  test 'sec 4hour, updated at 1 day ago' do
    page = Page.new(sec: 4.hours.seconds, updated_at: 2.days.ago)
    assert_equal(1.days.seconds, page.second)
  end
end
