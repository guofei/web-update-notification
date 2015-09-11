require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  setup do
    @page = pages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pages)
  end

  test "should create page" do
    assert_difference('Page.count') do
      post :create, page: { content: @page.content, hash: @page.hash, sec: @page.sec, uri: @page.uri, uuid: @page.uuid }
    end

    assert_response 201
  end

  test "should show page" do
    get :show, id: @page
    assert_response :success
  end

  test "should update page" do
    put :update, id: @page, page: { content: @page.content, hash: @page.hash, sec: @page.sec, uri: @page.uri, uuid: @page.uuid }
    assert_response 204
  end

  test "should destroy page" do
    assert_difference('Page.count', -1) do
      delete :destroy, id: @page
    end

    assert_response 204
  end
end
