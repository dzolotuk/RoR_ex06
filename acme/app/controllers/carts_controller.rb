class CartsController < ApplicationController
  def show; end

  # Cancel the cart: the cart and all its items are destroyed.
  def destroy
    current_cart.destroy!
    redirect_to products_path, notice: 'Your cart was cancelled', status: :see_other
  end
end
