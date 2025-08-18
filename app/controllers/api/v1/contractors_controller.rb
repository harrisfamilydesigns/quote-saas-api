class Api::V1::ContractorsController < Api::V1::BaseController
  # GET /api/v1/contractors
  def index
    contractors = Contractor.all
    render json: ContractorSerializer.new(contractors).serialize(as_array: true)
  end

  # GET /api/v1/contractors/:id
  def show
    contractor = Contractor.find(params[:id])
    render json: ContractorSerializer.new(contractor).serialize
  end
end
