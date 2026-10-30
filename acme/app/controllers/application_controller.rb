class ApplicationController < ActionController::Base
  include CurrentCart

  before_action :configure_permitted_parameters, if: :devise_controller?

  # No Rails error page for a wrong id or a form sent without its fields.
  rescue_from ActiveRecord::RecordNotFound, ActionController::ParameterMissing do
    redirect_to main_app.root_path, alert: 'This page does not exist', status: :see_other
  end

  # A form kept open for too long (the session changed in between).
  rescue_from ActionController::InvalidAuthenticityToken do
    redirect_to main_app.root_path, alert: 'The page was too old, please try again', status: :see_other
  end

  # A page of the administration panel typed by hand without the right role.
  # (RailsAdmin controllers inherit from this one.)
  rescue_from CanCan::AccessDenied do
    redirect_to main_app.root_path, alert: 'You are not allowed to do this', status: :see_other
  end

  protected

  # Strong parameters of Devise: the name and the biography are accepted
  # when an account is created and when it is edited. The roles are never accepted here.
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name bio])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name bio])
  end
end
