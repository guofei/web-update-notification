# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string
#  channel    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_channel  (channel) UNIQUE
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
