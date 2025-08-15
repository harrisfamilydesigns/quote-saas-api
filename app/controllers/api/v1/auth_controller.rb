class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:register, :login], raise: false
  
  # POST /api/v1/auth/register
  def register
    user = User.new(user_params)
    
    if user.save
      render json: {
        message: 'User registered successfully',
        user: UserSerializer.new(user).serialize
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # POST /api/v1/auth/login
  def login
    user = User.find_by(email: params[:user][:email])
    
    if user&.valid_password?(params[:user][:password])
      sign_in(user)
      render json: {
        message: 'Logged in successfully',
        user: UserSerializer.new(user).serialize
      }, status: :ok
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
    if current_user.nil?
      render json: { error: 'Not authenticated' }, status: :unauthorized
      return
    end
    
    render json: { user: UserSerializer.new(current_user).serialize }, status: :ok
  end
  
  private
  
  def user_params
    params.require(:user).permit(:email, :password, :role, :contractor_id, :supplier_id)
  end
end
