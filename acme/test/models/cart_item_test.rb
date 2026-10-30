require 'test_helper'

class CartItemTest < ActiveSupport::TestCase
  setup do
    @cart = Cart.create!(session_id: 'abc')
    @product = create_product(price: 4)
    @item = @cart.add(@product)
  end

  test 'the price of a line is quantity * price' do
    @item.update!(quantity: 3)
    assert_equal 12, @item.line_total
  end

  test 'increase and decrease change the quantity' do
    @item.increase
    assert_equal 2, @item.quantity
    @item.decrease
    assert_equal 1, @item.quantity
  end

  test 'decreasing the last unit removes the line' do
    assert_difference('CartItem.count', -1) { @item.decrease }
  end

  test 'the quantity is a positive whole number' do
    [0, -1, 1.5].each do |quantity|
      @item.quantity = quantity
      assert_not @item.valid?, "#{quantity} should be refused"
    end
  end

  test 'a product appears once in a cart' do
    assert_not CartItem.new(cart: @cart, product: @product).valid?
  end

  test 'deleting a product removes it from the carts' do
    assert_difference('CartItem.count', -1) { @product.destroy }
  end
end
