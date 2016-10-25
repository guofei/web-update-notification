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
  test 'sec 1minute, updated at 4 minutes ago' do
    page = Page.new(sec: 60, updated_at: 4.minutes.ago, created_at: 10.days.ago)
    assert_equal(4.minutes.seconds, page.second)
  end

  test 'sec 1minute, updated at 10 minutes ago' do
    page = Page.new(sec: 60, updated_at: 10.minutes.ago, created_at: 10.days.ago)
    assert_equal(10.minutes.seconds, page.second)
  end

  test 'sec 1minute, updated at 20 minutes ago' do
    page = Page.new(sec: 60, updated_at: 20.minutes.ago, created_at: 10.days.ago)
    assert_equal(20.minutes.seconds, page.second)
  end

  test 'sec 1minute, updated at 3 days ago' do
    page = Page.new(sec: 60, updated_at: 3.days.ago, created_at: 10.days.ago)
    assert_equal(1.hours.seconds, page.second)
  end

  test 'sec 1hours, updated at 40minutes ago' do
    page = Page.new(sec: 1.hours.seconds, updated_at: 40.minutes.ago, created_at: 10.days.ago)
    assert_equal(1.hours.seconds, page.second)
  end

  test 'sec 1hours, updated at 2hours ago' do
    page = Page.new(sec: 1.hours.seconds, updated_at: 2.hours.ago, created_at: 10.days.ago)
    assert_equal(1.hours.seconds, page.second)
  end

  test 'sec 1hours, updated at 3days ago' do
    page = Page.new(sec: 1.hours.seconds, updated_at: 3.days.ago, created_at: 10.days.ago)
    assert_equal(6.hours.seconds, page.second)
  end

  test 'sec 4hour, updated at 20 minutes ago' do
    page = Page.new(sec: 4.hours.seconds, updated_at: 20.minutes.ago, created_at: 10.days.ago)
    assert_equal(4.hours.seconds, page.second)
  end

  test 'sec 4hour, updated at 1 day ago' do
    page = Page.new(sec: 4.hours.seconds, updated_at: 2.days.ago, created_at: 10.days.ago)
    assert_equal(1.days.seconds, page.second)
  end

  test 'sec 4hour, updated at 3 day ago' do
    page = Page.new(sec: 4.hours.seconds, updated_at: 3.days.ago, created_at: 10.days.ago)
    assert_equal(2.days.seconds, page.second)
  end
end
