require 'test_helper'

class ShoppingCartTest < ActionDispatch::IntegrationTest
  setup do
    @brand = create_brand(name: 'Wile')
    @anvil = create_product(brand: @brand, name: 'Anvil', price: 10)
    @rocket = create_product(brand: @brand, name: 'Rocket', price: 2.5)
  end

  def add(product)
    post cart_items_path, params: { product_id: product.id }
  end

  def item_of(product)
    Cart.first.cart_items.find_by!(product: product)
  end

  test 'the catalog has a Cart section and an Add to cart button on each product' do
    get products_path
    assert_match(/<section id="cart">/, response.body)
    assert_match(/Your cart is empty/, response.body)
    assert_equal 2, response.body.scan('Add to cart').size
  end

  test 'a visitor adds a product, the cart shows it with the quantity and the price' do
    add @anvil
    assert_redirected_to cart_path
    follow_redirect!
    assert_match(/Anvil/, response.body)
    assert_match(%r{<td class="quantity">1</td>}, response.body)
    assert_match(/10\.00 €/, response.body)
  end

  test 'adding from the catalog comes back to the catalog' do
    post cart_items_path, params: { product_id: @anvil.id }, headers: { 'HTTP_REFERER' => products_url }
    assert_redirected_to products_url
    follow_redirect!
    assert_match(/Anvil was added to your cart/, response.body)
    assert_match(/id="cart_item_/, response.body)
  end

  test 'adding the same product twice makes quantity 2 and a line of quantity * price' do
    2.times { add @anvil }
    get cart_path
    assert_match(%r{<td class="quantity">2</td>}, response.body)
    assert_match(/20\.00 €/, response.body)
    assert_equal 1, CartItem.count
  end

  test 'the cart shows the total' do
    2.times { add @anvil }
    add @rocket
    get cart_path
    assert_match(%r{<th class="total">22\.50 €</th>}, response.body)
  end

  test 'plus and minus change the quantity' do
    add @anvil
    patch increase_cart_item_path(item_of(@anvil))
    patch increase_cart_item_path(item_of(@anvil))
    assert_equal 3, item_of(@anvil).quantity
    patch decrease_cart_item_path(item_of(@anvil))
    assert_equal 2, item_of(@anvil).quantity
  end

  test 'minus on a quantity of 1 removes the line' do
    add @anvil
    assert_difference('CartItem.count', -1) { patch decrease_cart_item_path(item_of(@anvil)) }
  end

  test 'a line can be removed' do
    add @anvil
    assert_difference('CartItem.count', -1) { delete cart_item_path(item_of(@anvil)) }
  end

  test 'cancelling the cart destroys it and its items' do
    add @anvil
    add @rocket
    assert_difference({ 'Cart.count' => -1, 'CartItem.count' => -2 }) { delete cart_path }
    assert_redirected_to products_path
    follow_redirect!
    assert_match(/Your cart was cancelled/, response.body)
    assert_match(/Your cart is empty/, response.body)
  end

  test 'a product that does not exist cannot be added' do
    assert_no_difference('CartItem.count') { post cart_items_path, params: { product_id: 0 } }
    assert_redirected_to root_path
  end

  test 'a request without product is refused without error page' do
    post cart_items_path
    assert_redirected_to root_path
  end

  test 'every visitor has his own cart' do
    add @anvil
    other = new_visitor
    other.post cart_items_path, params: { product_id: @rocket.id }
    assert_equal 2, Cart.count
    get cart_path
    assert_match(/Anvil/, response.body)
    assert_no_match(/Rocket/, response.body)
  end

  test 'the items of the cart of somebody else cannot be changed' do
    add @anvil
    foreign_id = item_of(@anvil).id
    other = new_visitor
    other.patch "/cart_items/#{foreign_id}/increase"
    assert_equal 1, item_of(@anvil).quantity
    other.delete "/cart_items/#{foreign_id}"
    assert CartItem.exists?(foreign_id)
  end

  test 'the cart is found again when the browser is closed and opened later' do
    add @anvil
    # the session cookie has an expiry date: it is kept when the browser is closed
    assert_match(/_acme_session=.*expires=/i, response.headers['Set-Cookie'])
    saved_cookie = cookies['_acme_session']

    returning = new_visitor
    returning.cookies['_acme_session'] = saved_cookie
    returning.get cart_path
    assert_match(/Anvil/, returning.response.body)
    assert_equal 1, Cart.count
  end

  test 'the cart follows the user when he logs in' do
    create_user
    add @anvil
    post user_session_path, params: { user: { email: 'alice@example.com', password: 'secret123' } }
    get cart_path
    assert_match(/Anvil/, response.body)
    assert_equal 1, Cart.count
  end

  test 'the cart section is also on the page of a product and of a brand' do
    get product_path(@anvil)
    assert_match(/<section id="cart">/, response.body)
    get brand_path(@brand)
    assert_match(/<section id="cart">/, response.body)
  end
end
