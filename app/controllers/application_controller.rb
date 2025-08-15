class ApplicationController < ActionController::API
  respond_to :json
  
  # Handle JWT token errors
  rescue_from JWT::VerificationError, JWT::DecodeError do
    render json: { error: 'Invalid token' }, status: :unauthorized
  end
end
