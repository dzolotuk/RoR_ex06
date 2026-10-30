# The session lives 30 days: the user closes the browser, comes back, and finds the cart again.
Rails.application.config.session_store :cookie_store, key: '_acme_session', expire_after: 30.days
