# The cart of the visitor, found with the session id. To use it in a controller:
# it is already included in ApplicationController, so every controller has current_cart.
module CurrentCart
  extend ActiveSupport::Concern

  included do
    helper_method :current_cart
  end

  private

  # The cart of this session (created the first time it is needed).
  def current_cart
    @current_cart ||= Cart.find_or_create_by!(session_id: cart_session_id)
  end

  # The id of the session of the visitor. A new session has no id yet in Rails (session.id is nil
  # until the cookie is sent), so the id is made once and kept inside the session. It stays the same
  # when Devise renews the session on login, so the cart is not lost.
  def cart_session_id
    session[:cart_session_id] ||= SecureRandom.uuid
  end
end
