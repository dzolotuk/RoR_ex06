require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  test 'two roles are available: administrator and moderator' do
    assert_equal %w[administrator moderator], Role::NAMES
    Role::NAMES.each { |name| assert Role.new(name: name).valid? }
  end

  test 'another role is refused' do
    assert_not Role.new(name: 'king').valid?
  end

  test 'a user gets a role with rolify' do
    user = create_user
    assert_not user.administrator?
    user.add_role(:administrator)
    assert user.administrator?
    assert_not user.moderator?
    assert_equal ['administrator'], user.roles.map(&:name)
  end

  test 'a user can lose a role' do
    user = create_user_with_role(:moderator)
    user.remove_role(:moderator)
    assert_not user.moderator?
  end

  test 'a new user has no role' do
    assert_empty create_user.roles
  end
end
