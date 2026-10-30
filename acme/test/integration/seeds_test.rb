require 'test_helper'

class SeedsTest < ActionDispatch::IntegrationTest
  def run_seeds(brands: 1, products: 1, password: nil)
    ENV['SEED_BRANDS'] = brands.to_s
    ENV['SEED_PRODUCTS_PER_BRAND'] = products.to_s
    ENV['SEED_PASSWORD'] = password if password
    capture_io { load Rails.root.join('db/seeds.rb') }
  ensure
    %w[SEED_BRANDS SEED_PRODUCTS_PER_BRAND SEED_PASSWORD].each { |name| ENV.delete(name) }
  end

  test 'the seeds create 20 users: 1 administrator, 5 moderators and 14 regular users' do
    run_seeds
    assert_equal 20, User.count
    assert_equal 1, User.with_role(:administrator).count
    assert_equal 5, User.with_role(:moderator).count
    assert_equal 14, User.where.missing(:roles).count
  end

  test 'the accounts have known emails and the same password' do
    run_seeds
    %w[admin@gmail.com moderator1@gmail.com moderator5@gmail.com user1@gmail.com user14@gmail.com].each do |email|
      assert User.find_by!(email: email).valid_password?('password'), email
    end
    assert User.find_by!(email: 'admin@gmail.com').administrator?
    assert User.find_by!(email: 'moderator3@gmail.com').moderator?
  end

  test 'the password of the accounts can be chosen' do
    run_seeds(password: 'a-better-password')
    assert User.find_by!(email: 'admin@gmail.com').valid_password?('a-better-password')
    assert User.find_by!(email: 'user7@gmail.com').valid_password?('a-better-password')
  end

  test 'the seeds create the brands and their products with images' do
    run_seeds(brands: 3, products: 4)
    assert_equal 3, Brand.count
    assert_equal 12, Product.count
    assert Brand.all.all? { |brand| brand.avatar.present? && brand.products.count == 4 }
    assert Product.all.all? { |product| product.pict.present? && product.price.positive? }
  end

  test 'the seeds can be run twice without doubling the data' do
    2.times { run_seeds(brands: 1, products: 2) }
    assert_equal 20, User.count
    assert_equal 2, Role.count
    assert_equal 1, Brand.count
    assert_equal 2, Product.count
  end

  test 'the default size of the catalog is 50 brands of 50 products = 2500 products' do
    source = File.read(Rails.root.join('db/seeds.rb'))
    assert_match(/'SEED_BRANDS', 50/, source)
    assert_match(/'SEED_PRODUCTS_PER_BRAND', 50/, source)
  end
end
