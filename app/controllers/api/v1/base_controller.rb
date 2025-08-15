class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user!
  
  private
  
  # Check if current user is a contractor
  def require_contractor
    unless current_user&.contractor_user?
      render json: { error: 'Access denied. Contractor account required.' }, status: :forbidden
    end
  end
  
  # Check if current user is a supplier
  def require_supplier
    unless current_user&.supplier_user?
      render json: { error: 'Access denied. Supplier account required.' }, status: :forbidden
    end
  end
  
  # Check if current user is an admin
  def require_admin
    unless current_user&.admin_user?
      render json: { error: 'Access denied. Admin account required.' }, status: :forbidden
    end
  end
end
