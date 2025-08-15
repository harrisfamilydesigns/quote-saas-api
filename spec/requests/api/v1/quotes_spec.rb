require 'rails_helper'

RSpec.describe "Api::V1::Quotes", type: :request do
  describe "GET /api/v1/material_requests/:material_request_id/quotes" do
    let(:contractor_user) { create(:contractor_user) }
    let(:project) { create(:project, contractor: contractor_user.contractor) }
    let(:material_request) { create(:material_request, project: project) }
    let!(:quotes) { create_list(:quote, 3, material_request: material_request) }
    
    context "as the project owner" do
      before do
        sign_in contractor_user
      end
      
      it "returns all quotes for the material request" do
        get "/api/v1/material_requests/#{material_request.id}/quotes"
        
        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.length).to eq(3)
      end
    end
    
    context "as a supplier with access" do
      let(:supplier_user) { create(:supplier_user) }
      let!(:quote) { create(:quote, material_request: material_request, supplier: supplier_user.supplier) }
      
      before do
        sign_in supplier_user
        create(:material_request_supplier, material_request: material_request, supplier: supplier_user.supplier)
      end
      
      it "returns quotes for the material request" do
        get "/api/v1/material_requests/#{material_request.id}/quotes"
        
        expect(response).to have_http_status(:ok)
      end
    end
  end
  
  describe "POST /api/v1/material_requests/:material_request_id/quotes" do
    let(:supplier_user) { create(:supplier_user) }
    let(:project) { create(:open_project) }
    let(:material_request) { create(:material_request, project: project) }
    
    before do
      sign_in supplier_user
      create(:material_request_supplier, material_request: material_request, supplier: supplier_user.supplier)
    end
    
    let(:valid_attributes) do
      {
        quote: {
          price: 1000,
          lead_time_days: 14
        }
      }
    end
    
    context "with valid parameters" do
      it "creates a new quote" do
        expect {
          post "/api/v1/material_requests/#{material_request.id}/quotes", params: valid_attributes
        }.to change(Quote, :count).by(1)
        
        expect(response).to have_http_status(:created)
        quote = Quote.last
        expect(quote.price).to eq(1000)
        expect(quote.supplier).to eq(supplier_user.supplier)
      end
    end
  end
  
  describe "PUT /api/v1/quotes/:id" do
    context "as a supplier updating their own quote" do
      let(:supplier_user) { create(:supplier_user) }
      let(:quote) { create(:quote, supplier: supplier_user.supplier) }
      
      before do
        sign_in supplier_user
      end
      
      let(:update_attributes) do
        {
          quote: {
            price: 1200,
            lead_time_days: 10
          }
        }
      end
      
      it "updates the quote" do
        put "/api/v1/quotes/#{quote.id}", params: update_attributes
        
        expect(response).to have_http_status(:ok)
        quote.reload
        expect(quote.price).to eq(1200)
        expect(quote.lead_time_days).to eq(10)
      end
    end
    
    context "as a contractor updating quote status" do
      let(:contractor_user) { create(:contractor_user) }
      let(:project) { create(:project, contractor: contractor_user.contractor) }
      let(:material_request) { create(:material_request, project: project) }
      let(:quote) { create(:quote, material_request: material_request) }
      
      before do
        sign_in contractor_user
      end
      
      let(:status_update) do
        {
          quote: {
            status: "accepted"
          }
        }
      end
      
      it "updates the quote status" do
        put "/api/v1/quotes/#{quote.id}", params: status_update
        
        expect(response).to have_http_status(:ok)
        quote.reload
        expect(quote.status).to eq("accepted")
      end
    end
  end
  
  describe "DELETE /api/v1/quotes/:id" do
    let(:supplier_user) { create(:supplier_user) }
    let!(:quote) { create(:quote, supplier: supplier_user.supplier) }
    
    before do
      sign_in supplier_user
    end
    
    it "deletes the quote" do
      expect {
        delete "/api/v1/quotes/#{quote.id}"
      }.to change(Quote, :count).by(-1)
      
      expect(response).to have_http_status(:no_content)
    end
  end
end