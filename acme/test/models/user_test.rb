require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'a user needs a name, an email and a password' do
    user = User.new
    assert_not user.valid?
    assert user.errors.of_kind?(:name, :blank)
    assert user.errors.of_kind?(:email, :blank)
    assert user.errors.of_kind?(:password, :blank)
  end

  test 'the biography is optional' do
    user = create_user
    assert_nil user.bio
    assert user.valid?
  end

  test 'the email must be valid and unique' do
    create_user(name: 'alice', email: 'a@example.com')
    assert_not User.new(name: 'bob', email: 'a@example.com', password: 'secret123').valid?
    assert_not User.new(name: 'bob', email: 'not an email', password: 'secret123').valid?
  end

  test 'the password is confirmed and long enough' do
    assert_not User.new(name: 'bob', email: 'b@example.com', password: 'secret123',
                        password_confirmation: 'other').valid?
    assert_not User.new(name: 'bob', email: 'b@example.com', password: '123').valid?
  end

  test 'the password is stored encrypted' do
    user = create_user(password: 'secret123')
    assert_not_equal 'secret123', user.encrypted_password
    assert user.valid_password?('secret123')
  end
end
