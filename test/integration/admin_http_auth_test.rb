require 'test_helper'

class AdminHttpAuthTest < ActionDispatch::IntegrationTest
  def test_access_granted
    get(
      "/admin", nil,
      'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(APP_CONFIG['admins'][0]['login'], APP_CONFIG['admins'][0]['password'])
    )
  
    assert_equal 200, status
  end
  def test_access_denied
    get(
      "/admin", nil,
      'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials('foo', 'bar')
    )
  
    assert_equal 401, status
  end
end
