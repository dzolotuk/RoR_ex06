require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  setup do
    @brand = create_brand
    @product = create_product(brand: @brand)
    @other_user = create_user(name: 'bob')
  end

  def ability_of(user)
    Ability.new(user)
  end

  test 'an administrator can edit everything' do
    ability = ability_of(create_user_with_role(:administrator))
    [Brand, Product, User, Role, Order, Cart].each do |model|
      %i[read create update destroy].each { |action| assert ability.can?(action, model), "#{action} #{model}" }
    end
    assert ability.can?(:access, :rails_admin)
    assert ability.can?(:update, @other_user)
  end

  test 'a moderator can create, modify and delete the brands and the products' do
    ability = ability_of(create_user_with_role(:moderator))
    [Brand, Product, @brand, @product].each do |subject|
      %i[read create update destroy].each { |action| assert ability.can?(action, subject), "#{action} #{subject}" }
    end
    assert ability.can?(:access, :rails_admin)
    assert ability.can?(:read, :dashboard)
  end

  test 'a moderator can do nothing else' do
    ability = ability_of(create_user_with_role(:moderator))
    [User, Role, Order, OrderItem, Cart, CartItem, @other_user].each do |subject|
      %i[read create update destroy].each { |action| assert ability.cannot?(action, subject), "#{action} #{subject}" }
    end
  end

  test 'a regular user can do nothing in the panel' do
    ability = ability_of(create_user)
    assert ability.cannot?(:access, :rails_admin)
    [Brand, Product, User, Role].each do |model|
      %i[read create update destroy].each { |action| assert ability.cannot?(action, model), "#{action} #{model}" }
    end
  end

  test 'a visitor can do nothing' do
    ability = ability_of(nil)
    assert ability.cannot?(:access, :rails_admin)
    assert ability.cannot?(:read, Product)
  end
end
