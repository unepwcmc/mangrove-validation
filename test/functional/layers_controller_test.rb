require 'test_helper'

class LayersControllerTest < ActionController::TestCase
  setup do
    @layer = layers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:layers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create layer" do
    assert_difference('Layer.count') do
      post :create, layer: @layer.attributes
    end

    assert_redirected_to layer_path(assigns(:layer))
  end

  test "should show layer" do
    get :show, id: @layer
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @layer
    assert_response :success
  end

  test "should update layer" do
    put :update, id: @layer, layer: @layer.attributes
    assert_redirected_to layer_path(assigns(:layer))
  end

  test "should destroy layer" do
    assert_difference('Layer.count', -1) do
      delete :destroy, id: @layer
    end

    assert_redirected_to layers_path
  end
end
