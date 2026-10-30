require 'test_helper'

class CartTest < ActiveSupport::TestCase
  setup do
    @cart = Cart.create!(session_id: 'abc')
    @anvil = create_product(name: 'Anvil', price: 10)
    @rocket = create_product(name: 'Rocket', price: 2.5, brand: @anvil.brand)
  end

  test 'adding a product creates an item of quantity 1' do
    item = @cart.add(@anvil)
    assert_equal [@anvil, 1], [item.product, item.quantity]
  end

  test 'adding the same product again increases the quantity' do
    2.times { @cart.add(@anvil) }
    assert_equal 1, @cart.cart_items.count
    assert_equal 2, @cart.cart_items.first.quantity
  end

  test 'the total is the sum of quantity * price of the items' do
    2.times { @cart.add(@anvil) }
    @cart.add(@rocket)
    assert_equal BigDecimal('22.5'), @cart.total
  end

  test 'an empty cart has a total of 0' do
    assert @cart.empty?
    assert_equal 0, @cart.total
  end

  test 'the items are destroyed with the cart' do
    @cart.add(@anvil)
    @cart.add(@rocket)
    assert_difference('CartItem.count', -2) { @cart.destroy }
  end

  test 'a session has only one cart' do
    assert_raises(ActiveRecord::RecordNotUnique) { Cart.create!(session_id: 'abc') }
  end

  test 'the abandoned carts are removed with their items' do
    old = Cart.create!(session_id: 'old')
    old.add(@anvil)
    old.update_columns(updated_at: 31.days.ago)
    @cart.add(@rocket)
    assert_equal [old], Cart.abandoned.to_a
    assert_difference({ 'Cart.count' => -1, 'CartItem.count' => -1 }) { assert_equal 1, Cart.purge_abandoned }
    assert Cart.exists?(@cart.id)
  end
end
