class Order < ApplicationRecord
  belongs_to :user, optional: true
  has_many :order_items, -> { order(:id) }, dependent: :destroy

  # The cart is validated: its items become the items of an order and the cart is destroyed.
  # Returns nil when the cart is empty.
  def self.from_cart(cart, user: nil)
    return if cart.empty?

    transaction do
      order = create!(session_id: cart.session_id, user: user)
      order.copy_items_of(cart)
      cart.destroy!
      order
    end
  end

  def copy_items_of(cart)
    cart.cart_items.includes(:product).each { |item| order_items.create!(OrderItem.copy_of(item)) }
  end

  def total
    order_items.sum(&:line_total)
  end
end
