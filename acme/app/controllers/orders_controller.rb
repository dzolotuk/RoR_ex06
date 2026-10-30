class OrdersController < ApplicationController
  # "Checkout" button: the cart becomes an order.
  def create
    order = Order.from_cart(current_cart, user: current_user)
    if order
      redirect_to order_path(order), status: :see_other
    else
      redirect_to cart_path, alert: 'Your cart is empty', status: :see_other
    end
  end

  # The summary of the order, only for the visitor who made it.
  def show
    @order = Order.includes(:order_items).find_by!(id: params[:id], session_id: cart_session_id)
  end
end
