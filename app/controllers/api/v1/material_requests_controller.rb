class Api::V1::MaterialRequestsController < Api::V1::BaseController
  before_action :set_project, only: [ :index, :create ]
  before_action :set_material_request, only: [ :show, :update, :destroy ]
  before_action :require_contractor, except: [ :show, :index ]
  before_action :authorize_access, only: [ :show, :index ]

  # GET /api/v1/projects/:project_id/material_requests
  def index
    if current_user.supplier_user?
      material_requests = @project.material_requests.joins(:material_request_suppliers)
        .where(material_request_suppliers: { supplier_id: current_user.supplier_id })
    else
      # Contractors can see all material requests for their project
      material_requests = @project.material_requests
    end

    # puts "Material requests for project #{@project.id}: count: #{material_requests.count}, #{material_requests.inspect}"
    response = MaterialRequestSerializer.new(material_requests).serialize
    # puts "Serialized response: #{response.inspect}"
    render json: response, status: :ok
  end

  # GET /api/v1/material_requests/:id
  def show
    # Create serialized data
    render json: MaterialRequestSerializer.new(@material_request).serialize
  end

  # POST /api/v1/projects/:project_id/material_requests
  def create
    material_request = @project.material_requests.new(material_request_params)

    if material_request.save
      # Handle supplier invitations if supplier_ids are provided
      if @supplier_ids.present?
        @supplier_ids.each do |supplier_id|
          material_request.material_request_suppliers.create(supplier_id: supplier_id)
        end
      end

      render json: MaterialRequestSerializer.new(material_request).serialize, status: :created
    else
      render json: { errors: material_request.errors.full_messages }, status: :unprocessable_content
    end
  end

  # PUT /api/v1/material_requests/:id
  def update
    if @material_request.update(material_request_params)
      render json: MaterialRequestSerializer.new(@material_request).serialize
    else
      render json: { errors: @material_request.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /api/v1/material_requests/:id
  def destroy
    @material_request.destroy
    head :no_content
  end

  # POST /api/v1/material_requests/:id/invite_suppliers
  def invite_suppliers
    set_material_request
    supplier_ids = params[:supplier_ids] || []

    supplier_ids.each do |supplier_id|
      @material_request.material_request_suppliers.find_or_create_by(supplier_id: supplier_id)
    end

    # Create response with suppliers
    render json: MaterialRequestSerializer.new(@material_request).serialize
  end

  # DELETE /api/v1/material_requests/:id/remove_supplier/:supplier_id
  def remove_supplier
    set_material_request
    supplier = Supplier.find(params[:supplier_id])
    @material_request.invited_suppliers.delete(supplier)

    # Create response with suppliers
    render json: MaterialRequestSerializer.new(@material_request).serialize
  end

  def units
    render json: { materialUnits: MaterialRequest::COMMON_UNITS }, status: :ok
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_material_request
    @material_request = MaterialRequest.find(params[:id])
  end

  def material_request_params
    # Remove supplier_ids from the params as it's not a material_request attribute
    permitted_params = params.require(:material_request).permit(:description, :quantity, :unit)
    @supplier_ids = params[:material_request][:supplier_ids] if params[:material_request][:supplier_ids].present?
    permitted_params
  end

  def authorize_access
    if current_user.contractor_user?
      # Contractors can only access their own projects' material requests
      project = @project || @material_request&.project
      if project&.contractor_id != current_user.contractor_id
        render json: { error: 'Unauthorized' }, status: :unauthorized
        nil
      end
    elsif current_user.supplier_user?
      # Suppliers can access material requests they're invited to or those that are open to all
      project = @project || @material_request&.project
      material_request = @material_request || (@project&.material_requests&.find_by(id: params[:id]))

      supplier_id = current_user.supplier_id

      # Check if supplier is invited to this material request
      is_invited = if material_request
        material_request.invited_suppliers.exists?(id: supplier_id) ||
        material_request.project.status == 'open'
      elsif project
        # For index action, allow if the project is open or if invited to any material request in project
        project.status == 'open' ||
        MaterialRequestSupplier.joins(:material_request)
          .where(material_requests: { project_id: project.id })
          .exists?(supplier_id: supplier_id)
      else
        false
      end

      unless is_invited
        render json: { error: 'You are not invited to view this material request' }, status: :unauthorized
        nil
      end
    end
  end
end
