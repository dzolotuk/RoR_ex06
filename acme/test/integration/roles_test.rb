require 'test_helper'

class RolesTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_user_with_role(:administrator, name: 'chief')
    @user = create_user(name: 'alice')
    Role.find_or_create_by!(name: 'moderator')
  end

  test 'the form of a user in the panel lists the two roles' do
    sign_in @admin
    get "/admin/user/#{@user.id}/edit"
    assert_response :success
    assert_match(/administrator/, response.body)
    assert_match(/moderator/, response.body)
  end

  test 'the administrator gives the moderator role to a user, then the user can moderate' do
    sign_in @admin
    moderator_role = Role.find_by!(name: 'moderator')
    put "/admin/user/#{@user.id}/edit", params: { user: { role_ids: [moderator_role.id.to_s] } }
    assert @user.reload.moderator?

    sign_out @admin
    sign_in @user
    get '/admin/product'
    assert_response :success
    get '/admin/user'
    assert_redirected_to '/'
  end

  test 'the administrator takes the role back' do
    @user.add_role(:moderator)
    sign_in @admin
    put "/admin/user/#{@user.id}/edit", params: { user: { name: 'alice', role_ids: [''] } }
    assert_not @user.reload.moderator?
    sign_out @admin
    sign_in @user
    get '/admin/product'
    assert_redirected_to '/'
  end

  test 'the administrator creates a role only with one of the two names' do
    sign_in @admin
    assert_no_difference('Role.count') { post '/admin/role/new', params: { role: { name: 'king' } } }
  end

  test 'nobody gets a role when registering, whatever the parameters' do
    admin_role = Role.find_or_create_by!(name: 'administrator')
    post user_registration_path, params: { user: { name: 'eve', email: 'eve@example.com', password: 'secret123',
                                                   password_confirmation: 'secret123',
                                                   role_ids: [admin_role.id], roles: ['administrator'] } }
    eve = User.find_by!(email: 'eve@example.com')
    assert_empty eve.roles
  end

  test 'nobody gets a role by editing his account, whatever the parameters' do
    admin_role = Role.find_or_create_by!(name: 'administrator')
    sign_in @user
    patch user_registration_path, params: { user: { name: 'alice', current_password: 'secret123',
                                                    role_ids: [admin_role.id] } }
    assert_empty @user.reload.roles
  end

  test 'the user does not keep the right of the panel after losing the role in the middle of the session' do
    @user.add_role(:moderator)
    sign_in @user
    get '/admin/product'
    assert_response :success
    @user.remove_role(:moderator)
    get '/admin/product'
    assert_redirected_to '/'
  end
end
