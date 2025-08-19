class Api::V1::QuotesController < Api::V1::BaseController
  before_action :set_material_request, only: [ :index, :create ]
  before_action :set_quote, only: [ :show, :update, :destroy ]
  before_action :authorize_access

  # GET /api/v1/material_requests/:material_request_id/quotes
  def index
    quotes = @material_request.quotes
    render json: QuoteSerializer.new(quotes).serialize
  end

  # GET /api/v1/quotes/:id
  def show
    render json: QuoteSerializer.new(@quote).serialize
  end

  # POST /api/v1/material_requests/:material_request_id/quotes
  def create
    quote = @material_request.quotes.new(quote_params)
    quote.supplier_id = current_user.supplier_id if current_user.supplier_user?

    if quote.save
      render json: QuoteSerializer.new(quote).serialize, status: :created
    else
      render json: { errors: quote.errors.full_messages }, status: :unprocessable_content
    end
  end

  # PUT /api/v1/quotes/:id
  def update
    if update_allowed?
      if @quote.update(update_params)
        render json: QuoteSerializer.new(@quote).serialize
      else
        render json: { errors: @quote.errors.full_messages }, status: :unprocessable_content
      end
    else
      render json: { error: 'You are not authorized to update this quote' }, status: :forbidden
    end
  end

  # DELETE /api/v1/quotes/:id
  def destroy
    if current_user.supplier_user? && @quote.supplier_id == current_user.supplier_id
      @quote.destroy
      head :no_content
    else
      render json: { error: 'You are not authorized to delete this quote' }, status: :forbidden
    end
  end

  private

  def set_material_request
    @material_request = MaterialRequest.find(params[:material_request_id])
  end

  def set_quote
    @quote = Quote.find(params[:id])
  end

  def quote_params
    # Only suppliers can set price and lead time
    if current_user.supplier_user?
      params.require(:quote).permit(:price, :lead_time_days)
    else
      {}
    end
  end

  def update_params
    if current_user.supplier_user? && @quote.supplier_id == current_user.supplier_id
      # Suppliers can update price and lead time if the quote is pending
      params.require(:quote).permit(:price, :lead_time_days)
    elsif current_user.contractor_user? && @quote.material_request.project.contractor_id == current_user.contractor_id
      # Contractors can only update status
      params.require(:quote).permit(:status)
    else
      {}
    end
  end

  def update_allowed?
    return true if current_user.supplier_user? && @quote.supplier_id == current_user.supplier_id
    return true if current_user.contractor_user? && @quote.material_request.project.contractor_id == current_user.contractor_id
    false
  end

  def authorize_access
    if current_user.contractor_user?
      # Contractors can only access quotes for their own projects
      material_request = @material_request || @quote&.material_request
      if material_request&.project&.contractor_id != current_user.contractor_id
        render json: { error: 'Unauthorized' }, status: :unauthorized
        nil
      end
    elsif current_user.supplier_user?
      # Suppliers can access quotes they've created or material requests they've been invited to quote on
      if @quote && @quote.supplier_id != current_user.supplier_id
        render json: { error: 'Unauthorized' }, status: :unauthorized
        nil
      end
    end
  end
end
