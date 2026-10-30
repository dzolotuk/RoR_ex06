require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  setup do
    @cart = Cart.create!(session_id: 'abc')
    @anvil = create_product(name: 'Anvil', price: 10)
    @rocket = create_product(name: 'Rocket', price: 2.5, brand: @anvil.brand)
    2.times { @cart.add(@anvil) }
    @cart.add(@rocket)
  end

  test 'the items of the cart are copied as items of an order' do
    order = Order.from_cart(@cart)
    assert_equal [['Anvil', 2, 10], ['Rocket', 1, 2.5]],
                 order.order_items.map { |item| [item.name, item.quantity, item.unit_price] }
    assert_equal BigDecimal('22.5'), order.total
    assert_equal 'abc', order.session_id
  end

  test 'the cart is destroyed with its items when it is validated' do
    assert_difference({ 'Cart.count' => -1, 'CartItem.count' => -2 }) { Order.from_cart(@cart) }
  end

  test 'an empty cart makes no order' do
    @cart.cart_items.destroy_all
    assert_no_difference('Order.count') { assert_nil Order.from_cart(@cart) }
    assert Cart.exists?(@cart.id)
  end

  test 'the order is linked to the user who made it' do
    user = create_user
    assert_equal user, Order.from_cart(@cart, user: user).user
  end

  test 'the order keeps the name and the price when the product changes or disappears' do
    order = Order.from_cart(@cart)
    @anvil.update!(price: 99, name: 'Golden anvil')
    @rocket.destroy
    order.reload
    assert_equal [['Anvil', 10], ['Rocket', 2.5]], order.order_items.map { |i| [i.name, i.unit_price] }
    assert_nil order.order_items.last.product
    assert_equal BigDecimal('22.5'), order.total
  end

  test 'the items are destroyed with the order' do
    order = Order.from_cart(@cart)
    assert_difference('OrderItem.count', -2) { order.destroy }
  end
end
