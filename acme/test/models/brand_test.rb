require 'test_helper'

class BrandTest < ActiveSupport::TestCase
  test 'a brand has a name and an image' do
    brand = create_brand(name: 'Wile')
    assert_equal 'Wile', brand.name
    assert brand.avatar.present?
    assert brand.avatar.thumb.present?
  end

  test 'the name and the image are mandatory' do
    brand = Brand.new
    assert_not brand.valid?
    assert brand.errors.of_kind?(:name, :blank)
    assert brand.errors.of_kind?(:avatar, :blank)
  end

  test 'a brand without name is not saved' do
    assert_raises(ActiveRecord::RecordInvalid) { Brand.create!(avatar: File.open(PICTURE)) }
  end

  test 'the products of a brand are destroyed with it' do
    product = create_product
    assert_difference('Product.count', -1) { product.brand.destroy }
  end

  test 'only images are accepted' do
    text = Tempfile.new(['notes', '.txt'])
    text.write('not an image')
    text.rewind
    brand = Brand.new(name: 'Wile', avatar: text)
    assert_not brand.valid?
    assert brand.errors.include?(:avatar)
  end
end
