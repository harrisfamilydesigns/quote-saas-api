class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [ :register, :login ], raise: false

  # POST /api/v1/auth/register
  def register
    user = User.new(user_params)

    ActiveRecord::Base.transaction do
      # Create associated entity based on role
      if user.role == User::ROLE_CONTRACTOR && !user.contractor_id
        contractor = Contractor.create(name: "Contractor #{user.email}", contact_email: user.email)
        user.contractor = contractor
      elsif user.role == User::ROLE_SUPPLIER && !user.supplier_id
        supplier = Supplier.create(name: "Supplier #{user.email}", contact_email: user.email)
        user.supplier = supplier
      end

      if user.save
        sign_in(user)

        # Generate JWT token
        token = request.env['warden-jwt_auth.token']

        # Add token to user for serialization
        user.instance_variable_set(:@auth_token, token)

        response = UserSerializer.new(user).serialize

        render json: response, status: :created
        return # return here to prevent further execution
      else
        raise ActiveRecord::Rollback
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  rescue => e
    render json: { errors: [ e.message ] }, status: :unprocessable_entity
  end

  # POST /api/v1/auth/login
  def login
    user = User.find_by(email: params[:user][:email])

    if user&.valid_password?(params[:user][:password])
      sign_in(user)

      # Reload the user to ensure we have the latest data including associations
      user.reload

      # Generate JWT token
      token = request.env['warden-jwt_auth.token']

      # Add token to user for serialization
      user.instance_variable_set(:@auth_token, token)

      response = UserSerializer.new(user).serialize

      render json: response, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  # DELETE /api/v1/auth/logout
  def logout
    sign_out(current_user)
    render json: { message: 'Logged out successfully' }, status: :ok
  end

  # GET /api/v1/auth/me
  def me
    # Log authentication information
    Rails.logger.debug 'AUTH /me REQUEST'
    Rails.logger.debug "Headers: #{request.headers.to_h.select { |k, _| k.start_with?('HTTP_') }}"
    Rails.logger.debug "Authorization: #{request.headers['Authorization']}"
    Rails.logger.debug "Warden: #{request.env['warden'].inspect}"
    Rails.logger.debug "Current user: #{current_user.inspect}"

    if current_user.nil?
      Rails.logger.debug 'AUTH FAILED: current_user is nil'
      render json: { error: 'Not authenticated' }, status: :unauthorized
      return
    end

    # Re-generate JWT token for the current session
    token = request.env['warden-jwt_auth.token']

    Rails.logger.debug "ME ENDPOINT TOKEN: #{token}"
    Rails.logger.debug "WARDEN-JWT TOKEN: #{request.env['warden-jwt_auth.token']}"

    if token.nil? && request.headers['Authorization'].present?
      # Extract token from Authorization header if not available in request env
      auth_header = request.headers['Authorization']
      Rails.logger.debug "Auth header: #{auth_header}"
      token = auth_header.split(' ').last if auth_header
      Rails.logger.debug "Extracted token: #{token}"
    end

    current_user.instance_variable_set(:@auth_token, token)

    response = UserSerializer.new(current_user).serialize

    render json: response, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :role, :contractor_id, :supplier_id)
  end
end
