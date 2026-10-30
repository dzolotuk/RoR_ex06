class Cart < ApplicationRecord
  ABANDONED_AFTER = 30.days

  # The items of a cancelled cart are destroyed with it.
  has_many :cart_items, -> { order(:id) }, dependent: :destroy, inverse_of: :cart

  scope :abandoned, -> { where(updated_at: ...ABANDONED_AFTER.ago) }

  # Carts nobody came back to are useless: removed with their items. Returns how many.
  def self.purge_abandoned
    abandoned.destroy_all.size
  end

  def add(product)
    item = cart_items.find_or_initialize_by(product: product)
    item.add_one
    touch
    item
  end

  def total
    cart_items.includes(:product).sum(&:line_total)
  end

  def empty?
    cart_items.empty?
  end
end
