require 'test_helper'

class PaginatorTest < ActiveSupport::TestCase
  setup do
    brand = create_brand
    3.times { |i| create_product(brand: brand, name: "Product #{i}") }
    stub_per_page(2)
  end

  teardown { restore_per_page }

  def stub_per_page(value)
    Paginator.send(:remove_const, :PER_PAGE)
    Paginator.const_set(:PER_PAGE, value)
  end

  def restore_per_page
    stub_per_page(50)
  end

  test 'the records are cut in pages' do
    first = Paginator.new(Product.order(:id), 1)
    second = Paginator.new(Product.order(:id), 2)
    assert_equal 2, first.total_pages
    assert_equal ['Product 0', 'Product 1'], first.records.map(&:name)
    assert_equal ['Product 2'], second.records.map(&:name)
  end

  test 'the links to the previous and to the next page' do
    first = Paginator.new(Product.order(:id), 1)
    assert_nil first.previous_page
    assert_equal 2, first.next_page
    last = Paginator.new(Product.order(:id), 2)
    assert_equal 1, last.previous_page
    assert_nil last.next_page
  end

  test 'a wrong page number gives the nearest real page' do
    assert_equal 1, Paginator.new(Product.order(:id), 'abc').number
    assert_equal 1, Paginator.new(Product.order(:id), '-4').number
    assert_equal 2, Paginator.new(Product.order(:id), '999').number
    assert_equal 1, Paginator.new(Product.order(:id), nil).number
  end

  test 'an empty list has one empty page' do
    paginator = Paginator.new(Product.none, 1)
    assert_equal 1, paginator.total_pages
    assert_empty paginator.records
  end
end
