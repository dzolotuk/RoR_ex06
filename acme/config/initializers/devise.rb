# Configuration of Devise (the default values of the gem are kept when a line is not here).
Devise.setup do |config|
  config.mailer_sender = 'no-reply@acme.example'

  require 'devise/orm/active_record'

  # The email is compared without the case and without the spaces around it.
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  config.skip_session_storage = [:http_auth]

  # Cost of the password hashing: 1 in the tests to keep them fast.
  config.stretches = Rails.env.test? ? 1 : 12

  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # The logout link is a DELETE request (a button, see the navigation bar).
  config.sign_out_via = :delete

  # Turbo needs these status codes to show the errors of a form and to follow a redirection.
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end
