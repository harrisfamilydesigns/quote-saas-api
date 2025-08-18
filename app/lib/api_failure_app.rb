class ApiFailureApp < Devise::FailureApp
  def respond
    json_api_error_response
  end

  def json_api_error_response
    self.status = 401
    self.content_type = 'application/json'
    self.response_body = { error: "Authentication failed: #{i18n_message}" }.to_json
  end

  # Override to avoid using sessions
  def store_location!
    # Do nothing - we don't want to store the location in session
  end
end
