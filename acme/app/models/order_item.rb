class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true

  validates :name, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }

  # The attributes of an order item that copies a cart item (the name and the price are kept as they were).
  def self.copy_of(cart_item)
    product = cart_item.product
    { product: product, name: product.name, unit_price: product.price, quantity: cart_item.quantity }
  end

  def line_total
    quantity * unit_price
  end
end
