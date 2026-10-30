require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  test 'a product has a name, an image, a description, a brand and a price' do
    product = create_product(name: 'Rocket', price: 49.99, description: 'Goes fast')
    product.reload
    assert_equal ['Rocket', 'Goes fast'], [product.name, product.description]
    assert_equal BigDecimal('49.99'), product.price
    assert product.pict.present?
    assert_equal 'Acme Corp', product.brand.name
  end

  test 'everything is mandatory' do
    product = Product.new
    assert_not product.valid?
    %i[name description pict brand].each do |field|
      assert product.errors.include?(field), "#{field} should be mandatory"
    end
    assert product.errors.include?(:price)
  end

  test 'the price cannot be negative' do
    brand = create_brand
    product = Product.new(name: 'Rocket', description: 'x', price: -1, brand: brand, pict: File.open(PICTURE))
    assert_not product.valid?
    assert product.errors.include?(:price)
  end

  test 'a product is made with a brand_id like in the seeds' do
    brand = create_brand
    product = Product.create!(name: 'Rocket', pict: File.open(PICTURE), description: 'x',
                              brand_id: brand.id, price: 9.99)
    assert_equal brand, product.brand
  end

  test 'the image has a thumbnail version' do
    product = create_product
    assert_match(%r{thumb}, product.pict.thumb.url.to_s)
  end
end
