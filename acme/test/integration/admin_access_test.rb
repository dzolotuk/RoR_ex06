require 'test_helper'

class AdminAccessTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_user_with_role(:administrator, name: 'chief')
    @moderator = create_user_with_role(:moderator, name: 'mod')
    @user = create_user(name: 'alice')
    @brand = create_brand(name: 'Wile')
    @product = create_product(brand: @brand, name: 'Anvil', price: 10)
  end

  def assert_refused(message = nil)
    assert_redirected_to '/', message
    follow_redirect!
    assert_match(/You are not allowed to do this/, response.body)
  end

  ### the link on the catalog page

  test 'the link to the panel is shown to the administrator and to the moderator' do
    [@admin, @moderator].each do |user|
      sign_in user
      get products_path
      assert_match(%r{<a href="/admin">Administration panel</a>}, response.body)
    end
  end

  test 'the link to the panel is hidden for a regular user and a visitor' do
    sign_in @user
    get products_path
    assert_no_match(/Administration panel/, response.body)
    sign_out @user
    get products_path
    assert_no_match(/Administration panel/, response.body)
  end

  ### the visitor and the regular user

  test 'a visitor is sent to the login page' do
    get '/admin'
    assert_redirected_to new_user_session_path
  end

  test 'a regular user can log in but cannot enter the panel, whatever the address' do
    sign_in @user
    ['/admin', '/admin/product', '/admin/brand/new', '/admin/user', "/admin/product/#{@product.id}/edit",
     "/admin/product/#{@product.id}"].each do |path|
      get path
      assert_refused "#{path} should be refused"
    end
  end

  test 'a regular user cannot change or delete anything with a hand made request' do
    sign_in @user
    put "/admin/product/#{@product.id}/edit", params: { product: { name: 'hacked' } }
    assert_refused
    delete "/admin/product/#{@product.id}/delete"
    assert_refused
    post '/admin/brand/new', params: { brand: { name: 'Mine' } }
    assert_refused
    assert_equal 'Anvil', @product.reload.name
    assert Product.exists?(@product.id)
    assert_nil Brand.find_by(name: 'Mine')
  end

  ### the administrator

  test 'an administrator opens every page of the panel' do
    sign_in @admin
    get '/admin'
    assert_response :success
    %w[user role brand product cart cart_item order order_item].each do |model|
      get "/admin/#{model}"
      assert_response :success, "/admin/#{model} should open"
    end
  end

  test 'an administrator edits a user and deletes a brand' do
    sign_in @admin
    put "/admin/user/#{@user.id}/edit", params: { user: { name: 'alicia' } }
    assert_equal 'alicia', @user.reload.name
    assert_difference('Brand.count', -1) { delete "/admin/brand/#{@brand.id}/delete" }
  end

  test 'editing a user in the panel without typing a password keeps the password' do
    sign_in @admin
    put "/admin/user/#{@user.id}/edit", params: { user: { name: 'alicia', password: '', password_confirmation: '' } }
    assert @user.reload.valid_password?('secret123')
  end

  ### the moderator

  test 'a moderator opens the dashboard and the brands and the products' do
    sign_in @moderator
    get '/admin'
    assert_response :success
    get '/admin/brand'
    assert_response :success
    get '/admin/product'
    assert_response :success
    assert_match(/Anvil/, response.body)
  end

  test 'a moderator does not see the other models in the panel' do
    sign_in @moderator
    get '/admin'
    assert_no_match(%r{/admin/user"}, response.body)
    assert_no_match(%r{/admin/order"}, response.body)
    assert_no_match(%r{/admin/role"}, response.body)
  end

  test 'a moderator creates, modifies and deletes brands and products' do
    sign_in @moderator
    image = Rack::Test::UploadedFile.new(PICTURE, 'image/png')
    assert_difference('Brand.count', 1) do
      post '/admin/brand/new', params: { brand: { name: 'Roadrunner', avatar: image } }
    end
    brand = Brand.find_by!(name: 'Roadrunner')
    put "/admin/brand/#{brand.id}/edit", params: { brand: { name: 'Road Runner' } }
    assert_equal 'Road Runner', brand.reload.name

    assert_difference('Product.count', 1) do
      post '/admin/product/new', params: { product: { name: 'Birdseed', description: 'Tasty', price: '3.5',
                                                      brand_id: brand.id, pict: image } }
    end
    put "/admin/product/#{@product.id}/edit", params: { product: { price: '12' } }
    assert_equal 12, @product.reload.price
    assert_difference('Product.count', -1) { delete "/admin/product/#{@product.id}/delete" }
  end

  test 'a moderator cannot reach the users, the roles and the orders even by typing the address' do
    sign_in @moderator
    %w[/admin/user /admin/user/new /admin/role /admin/role/new /admin/order /admin/cart /admin/order_item
       /admin/cart_item].each do |path|
      get path
      assert_refused "#{path} should be refused"
    end
    get "/admin/user/#{@user.id}"
    assert_refused
    get "/admin/user/#{@user.id}/edit"
    assert_refused
  end

  test 'a moderator cannot change a user, a role or delete somebody by a hand made request' do
    sign_in @moderator
    put "/admin/user/#{@user.id}/edit", params: { user: { name: 'hacked' } }
    assert_refused
    assert_no_difference('User.count') { delete "/admin/user/#{@user.id}/delete" }
    assert_no_difference('Role.count') { post '/admin/role/new', params: { role: { name: 'administrator' } } }
    assert_equal 'alice', @user.reload.name
  end

  test 'a moderator cannot give himself the administrator role' do
    sign_in @moderator
    admin_role = Role.find_by!(name: 'administrator')
    put "/admin/user/#{@moderator.id}/edit", params: { user: { role_ids: [admin_role.id] } }
    assert_not @moderator.reload.administrator?
  end
end
