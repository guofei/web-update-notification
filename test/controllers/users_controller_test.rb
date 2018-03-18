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

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
#   setup do
#     @user = users(:one)
#   end
# 
#   test "should get index" do
#     get :index
#     assert_response :success
#     assert_not_nil assigns(:users)
#   end
# 
#   test "should create user" do
#     assert_difference('User.count') do
#       post :create, user: { channel: @user.channel, name: @user.name }
#     end
# 
#     assert_response 201
#   end
# 
#   test "should show user" do
#     get :show, id: @user
#     assert_response :success
#   end
# 
#   test "should update user" do
#     put :update, id: @user, user: { channel: @user.channel, name: @user.name }
#     assert_response 204
#   end
# 
#   test "should destroy user" do
#     assert_difference('User.count', -1) do
#       delete :destroy, id: @user
#     end
# 
#     assert_response 204
#   end
end
