require 'test_helper'

class LoginTest < ActionDispatch::IntegrationTest
  setup { create_user(name: 'alice') }

  test 'a visitor sees the login and register links' do
    get root_path
    assert_match(/Login/, response.body)
    assert_match(/Register/, response.body)
    assert_no_match(/Logged as/, response.body)
  end

  test 'a user logs in with the email and the password, then logs out' do
    post user_session_path, params: { user: { email: 'alice@example.com', password: 'secret123' } }
    assert_redirected_to root_path
    follow_redirect!
    assert_match(/Logged as alice/, response.body)
    assert_match(/Logout/, response.body)

    delete destroy_user_session_path
    follow_redirect!
    assert_no_match(/Logged as/, response.body)
  end

  test 'a wrong password does not log in' do
    post user_session_path, params: { user: { email: 'alice@example.com', password: 'wrong' } }
    assert_response :unprocessable_entity
    assert_match(/Invalid Email or password/, response.body)
  end
end
