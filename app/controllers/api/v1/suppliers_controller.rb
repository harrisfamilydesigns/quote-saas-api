class Api::V1::SuppliersController < Api::V1::BaseController
  # GET /api/v1/suppliers
  def index
    suppliers = Supplier.all
    render json: SupplierSerializer.new(suppliers).serialize(as_array: true)
  end
  
  # GET /api/v1/suppliers/:id
  def show
    supplier = Supplier.find(params[:id])
    render json: SupplierSerializer.new(supplier).serialize
  end
end
