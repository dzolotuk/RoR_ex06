require 'test_helper'

class ErrorsTest < ActionDispatch::IntegrationTest
  test 'the root page works' do
    get root_path
    assert_response :success
    assert_match(/Catalog/, response.body)
  end

  test 'an address that does not exist goes back to the root page with a message' do
    get '/this/does/not/exist'
    assert_redirected_to root_path
    follow_redirect!
    assert_match(/This page does not exist/, response.body)
  end

  test 'the real addresses are not caught' do
    get new_user_session_path
    assert_response :success
  end

  test 'files other than pages are not caught (so no message for a missing icon)' do
    assert_raises(ActionController::RoutingError) { get '/missing.png' }
  end

  test 'a form sent with a wrong security token goes back to the root page' do
    ActionController::Base.allow_forgery_protection = true
    post user_session_path, params: { user: { email: 'a@example.com', password: 'secret123' } }
    assert_redirected_to root_path
    follow_redirect!
    assert_match(/The page was too old/, response.body)
  ensure
    ActionController::Base.allow_forgery_protection = false
  end
end
