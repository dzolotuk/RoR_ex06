class CartItemsController < ApplicationController
  before_action :find_item, only: %i[increase decrease destroy]

  # "Add to cart" button of a product.
  def create
    product = Product.find(params.require(:product_id))
    current_cart.add(product)
    back notice: "#{product.name} was added to your cart"
  end

  def increase
    @item.increase
    back
  end

  def decrease
    @item.decrease
    back
  end

  def destroy
    @item.destroy!
    back
  end

  private

  # Only the items of the cart of the visitor can be changed.
  def find_item
    @item = current_cart.cart_items.find(params[:id])
  end

  def back(flash = {})
    redirect_back fallback_location: cart_path, status: :see_other, **flash
  end
end
