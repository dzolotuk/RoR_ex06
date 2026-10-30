require 'test_helper'

class CatalogTest < ActionDispatch::IntegrationTest
  setup do
    @brand = create_brand(name: 'Wile')
    @anvil = create_product(brand: @brand, name: 'Anvil', price: 19.9)
    @rocket = create_product(brand: @brand, name: 'Rocket', price: 120)
  end

  test 'the root page is the catalog, for a visitor' do
    get root_path
    assert_response :success
    assert_match(/Catalog/, response.body)
    assert_match(/Anvil/, response.body)
    assert_match(/Rocket/, response.body)
  end

  test 'a logged in user sees the catalog' do
    sign_in create_user
    get root_path
    assert_response :success
    assert_match(/Logged as alice/, response.body)
    assert_match(/Anvil/, response.body)
  end

  test 'a product is listed with its name, its image, its brand and its price' do
    get products_path
    assert_match(/Anvil/, response.body)
    assert_match(/Wile/, response.body)
    assert_match(/19\.90 €/, response.body)
    assert_match(/120\.00 €/, response.body)
    assert_includes response.body, @anvil.pict.thumb.url
  end

  test 'the catalog shows the thumbnail version of the images, not the original' do
    get products_path
    assert_includes response.body, @anvil.pict.thumb.url
    assert_not_includes response.body, %("#{@anvil.pict.url}")
  end

  test 'the catalog is cut in pages' do
    Paginator.send(:remove_const, :PER_PAGE)
    Paginator.const_set(:PER_PAGE, 1)
    get products_path
    assert_match(/Page 1 \/ 2/, response.body)
    assert_match(/Anvil/, response.body)
    assert_no_match(/Rocket/, response.body)
    get products_path(page: 2)
    assert_match(/Rocket/, response.body)
    get products_path(page: 'abc')
    assert_response :success
  ensure
    Paginator.send(:remove_const, :PER_PAGE)
    Paginator.const_set(:PER_PAGE, 50)
  end

  test 'a product page shows the description, the brand and the price' do
    get product_path(@anvil)
    assert_response :success
    assert_match(/Very heavy/, response.body)
    assert_match(/Wile/, response.body)
    assert_match(/19\.90 €/, response.body)
    assert_includes response.body, @anvil.pict.thumb.url
  end

  test 'a product that does not exist goes back to the catalog with a message' do
    get product_path(0)
    assert_redirected_to root_path
    follow_redirect!
    assert_match(/This page does not exist/, response.body)
  end

  test 'the brands page lists the brands with their number of products' do
    get brands_path
    assert_match(/Wile/, response.body)
    assert_match(/2 products/, response.body)
  end

  test 'a brand page lists only its products' do
    other = create_product(name: 'Skates', brand: create_brand(name: 'Other'))
    get brand_path(@brand)
    assert_match(/Anvil/, response.body)
    assert_no_match(/#{other.name}/, response.body)
  end

  test 'an empty shop says that there is no product' do
    Product.destroy_all
    get root_path
    assert_match(/There is no product yet/, response.body)
  end
end
