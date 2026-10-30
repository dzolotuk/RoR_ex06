require 'test_helper'

class AccountTest < ActionDispatch::IntegrationTest
  setup { @user = create_user(name: 'alice', bio: 'old bio') }

  test 'the account page needs a login' do
    get edit_user_registration_path
    assert_redirected_to new_user_session_path
  end

  test 'the user edits the name, the email and the biography' do
    sign_in @user
    get edit_user_registration_path
    assert_response :success
    patch user_registration_path, params: { user: { name: 'alicia', email: 'alicia@example.com',
                                                    bio: 'new bio', current_password: 'secret123' } }
    assert_redirected_to root_path
    @user.reload
    assert_equal %w[alicia alicia@example.com], [@user.name, @user.email]
    assert_equal 'new bio', @user.bio
  end

  test 'the user changes the password' do
    sign_in @user
    patch user_registration_path, params: { user: { password: 'newsecret1', password_confirmation: 'newsecret1',
                                                    current_password: 'secret123' } }
    assert @user.reload.valid_password?('newsecret1')
  end

  test 'nothing is saved without the current password' do
    sign_in @user
    patch user_registration_path, params: { user: { name: 'hacker', current_password: 'wrong' } }
    assert_response :unprocessable_entity
    assert_equal 'alice', @user.reload.name
  end

  test 'the name cannot be emptied' do
    sign_in @user
    patch user_registration_path, params: { user: { name: '', current_password: 'secret123' } }
    assert_response :unprocessable_entity
    assert_equal 'alice', @user.reload.name
  end

  test 'a field that is not allowed is ignored' do
    sign_in @user
    patch user_registration_path, params: { user: { name: 'alice', current_password: 'secret123',
                                                    encrypted_password: 'x', id: 99 } }
    assert_not_equal 'x', @user.reload.encrypted_password
    assert_not_equal 99, @user.id
  end
end
