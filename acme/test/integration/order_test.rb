require 'test_helper'

class OrderFlowTest < ActionDispatch::IntegrationTest
  setup do
    brand = create_brand
    @anvil = create_product(brand: brand, name: 'Anvil', price: 10)
    @rocket = create_product(brand: brand, name: 'Rocket', price: 2.5)
    2.times { post cart_items_path, params: { product_id: @anvil.id } }
    post cart_items_path, params: { product_id: @rocket.id }
  end

  test 'the cart page has a Checkout button' do
    get cart_path
    assert_match(/Checkout/, response.body)
  end

  test 'checkout shows the summary of the order with the total price' do
    assert_difference('Order.count', 1) { post orders_path }
    assert_redirected_to order_path(Order.last)
    follow_redirect!
    assert_match(/Order summary/, response.body)
    assert_match(/Anvil/, response.body)
    assert_match(/Rocket/, response.body)
    assert_match(%r{<th class="total">22\.50 €</th>}, response.body)
  end

  test 'after the checkout the cart is empty and destroyed' do
    assert_difference({ 'Cart.count' => -1, 'CartItem.count' => -2 }) { post orders_path }
    get cart_path
    assert_match(/Your cart is empty/, response.body)
  end

  test 'a second checkout with an empty cart makes no order' do
    post orders_path
    assert_no_difference('Order.count') { post orders_path }
    assert_redirected_to cart_path
    follow_redirect!
    assert_match(/Your cart is empty/, response.body)
  end

  test 'a logged in user has his order linked to his account' do
    user = create_user
    sign_in user
    post orders_path
    assert_equal user, Order.last.user
  end

  test 'an order can be seen only by the visitor who made it' do
    post orders_path
    order = Order.last
    get order_path(order)
    assert_response :success
    stranger = new_visitor
    stranger.get order_path(order)
    assert_equal root_url, stranger.response.location
  end

  test 'an order that does not exist goes back to the catalog' do
    get order_path(0)
    assert_redirected_to root_path
  end
end
