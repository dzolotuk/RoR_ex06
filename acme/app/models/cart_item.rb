class CartItem < ApplicationRecord
  belongs_to :cart, inverse_of: :cart_items
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :product_id, uniqueness: { scope: :cart_id }

  # quantity * price
  def line_total
    quantity * product.price
  end

  # A new item starts with 1, an existing one gets one more.
  def add_one
    self.quantity = new_record? ? 1 : quantity + 1
    save!
  end

  def increase
    update!(quantity: quantity + 1)
  end

  # Going under 1 removes the line.
  def decrease
    quantity > 1 ? update!(quantity: quantity - 1) : destroy!
  end
end
