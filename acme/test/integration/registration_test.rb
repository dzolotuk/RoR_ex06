require 'test_helper'

class RegistrationTest < ActionDispatch::IntegrationTest
  def register(overrides = {})
    params = { name: 'alice', email: 'alice@example.com', password: 'secret123',
               password_confirmation: 'secret123', bio: 'I like shopping' }.merge(overrides)
    post user_registration_path, params: { user: params }
  end

  test 'the registration form asks the name, the email, the biography and the password' do
    get new_user_registration_path
    assert_response :success
    %w[user[name] user[email] user[bio] user[password] user[password_confirmation]].each do |field|
      assert_includes response.body, %(name="#{field}")
    end
  end

  test 'a visitor creates an account with all the fields and is logged in' do
    assert_difference('User.count', 1) { register }
    follow_redirect!
    assert_match(/Logged as alice/, response.body)
    user = User.find_by!(email: 'alice@example.com')
    assert_equal 'I like shopping', user.bio
    assert_equal 'alice', user.name
  end

  test 'the biography can be left empty' do
    assert_difference('User.count', 1) { register(bio: '') }
  end

  test 'the name, the email and the password are mandatory' do
    assert_no_difference('User.count') { register(name: '') }
    assert_response :unprocessable_entity
    assert_match(/Name can&#39;t be blank/, response.body)
    assert_no_difference('User.count') { register(email: '') }
    assert_no_difference('User.count') { register(password: '', password_confirmation: '') }
  end

  test 'two accounts cannot share an email' do
    register
    delete destroy_user_session_path
    assert_no_difference('User.count') { register(name: 'bob') }
    assert_match(/Email has already been taken/, response.body)
  end
end
