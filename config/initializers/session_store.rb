# Enable the session store for the application
Rails.application.config.session_store :cookie_store, key: '_quote_saas_api_session'
Rails.application.config.middleware.use ActionDispatch::Cookies
Rails.application.config.middleware.use Rails.application.config.session_store, Rails.application.config.session_options
