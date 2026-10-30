ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  PICTURE = Rails.root.join('db/seeds/placeholder.png')

  # Every test makes its own records (no fixtures).
  def create_user(name: 'alice', email: nil, password: 'secret123', bio: nil)
    User.create!(name: name, email: email || "#{name}@example.com", bio: bio,
                 password: password, password_confirmation: password)
  end

  def create_user_with_role(role, name: role.to_s)
    create_user(name: name).tap { |user| user.add_role(role) }
  end

  def create_brand(name: 'Acme Corp')
    Brand.create!(name: name, avatar: File.open(PICTURE))
  end

  def create_product(brand: nil, name: 'Anvil', price: 19.9, description: 'Very heavy')
    Product.create!(name: name, price: price, description: description, pict: File.open(PICTURE),
                    brand: brand || create_brand)
  end

  # The uploaded images of the tests are removed when the tests are finished.
  Minitest.after_run { FileUtils.rm_rf(Rails.root.join('tmp/test_uploads')) }
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # Another browser: its own cookies, so its own session and its own cart.
  def new_visitor
    ActionDispatch::Integration::Session.new(Rails.application)
  end
end
