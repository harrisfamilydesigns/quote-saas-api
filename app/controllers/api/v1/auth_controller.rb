class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [ :register, :login ], raise: false

  # POST /api/v1/auth/register
  def register
    user = User.new(user_params)

    ActiveRecord::Base.transaction do
      # Create associated entity based on role
      if user.role == User::ROLE_CONTRACTOR
        contractor = Contractor.create(name: "Contractor #{user.email}", contact_email: user.email)
        user.contractor = contractor
      elsif user.role == User::ROLE_SUPPLIER
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
        # Store errors before raising rollback
        @user_errors = user.errors.full_messages
        raise ActiveRecord::Rollback
      end
    end

    # Return errors after transaction if they exist
    if @user_errors.present?
      render json: { errors: @user_errors }, status: :unprocessable_content
    end
  rescue => e
    render json: { errors: [ e.message ] }, status: :unprocessable_content
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
      render json: { errors: [ 'Invalid email or password' ] }, status: :unauthorized
    end
  end

  # DELETE /api/v1/auth/logout
  def logout
    sign_out(current_user)
    render json: { user: nil, message: 'Logged out successfully' }, status: :ok
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
      render json: { errors: [ 'Not authenticated' ] }, status: :unauthorized
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
    # First, get basic params without role
    params_without_role = params.require(:user).permit(:email, :password)
    
    # Handle role separately with validation
    role = params[:user][:role]
    
    # Set safe default role
    safe_role = User::ROLE_CONTRACTOR
    
    # Validate role if present
    if role.present? && User::ROLES.include?(role) && role != User::ROLE_ADMIN
      safe_role = role
    end
    
    # Merge params
    params_without_role.merge(role: safe_role)
  end
end
