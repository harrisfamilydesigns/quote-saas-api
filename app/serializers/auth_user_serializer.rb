class AuthUserSerializer < UserSerializer
  attribute :token do |user|
    # Return the JWT token if it was set by the controller
    user.instance_variable_get(:@auth_token)
  end
end
