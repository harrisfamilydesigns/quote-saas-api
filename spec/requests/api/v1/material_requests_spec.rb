require 'rails_helper'

RSpec.describe "Api::V1::MaterialRequests", type: :request do
  describe "GET /api/v1/projects/:project_id/material_requests" do
    let(:contractor_user) { create(:contractor_user) }
    let(:project) { create(:project, contractor: contractor_user.contractor) }
    let!(:material_requests) { create_list(:material_request, 3, project: project) }
    
    context "as the project owner" do
      before do
        sign_in contractor_user
      end
      
      it "returns all material requests for the project" do
        get "/api/v1/projects/#{project.id}/material_requests"
        
        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.length).to eq(3)
      end
    end
    
    context "as a supplier with access" do
      let(:supplier_user) { create(:supplier_user) }
      let(:material_request) { material_requests.first }
      
      before do
        sign_in supplier_user
        create(:material_request_supplier, material_request: material_request, supplier: supplier_user.supplier)
      end
      
      it "returns material requests the supplier is invited to" do
        get "/api/v1/projects/#{project.id}/material_requests"
        
        expect(response).to have_http_status(:ok)
      end
    end
  end
  
  describe "GET /api/v1/material_requests/:id" do
    let(:contractor_user) { create(:contractor_user) }
    let(:project) { create(:project, contractor: contractor_user.contractor) }
    let(:material_request) { create(:material_request, project: project) }
    let!(:quotes) { create_list(:quote, 2, material_request: material_request) }
    
    context "as the project owner" do
      before do
        sign_in contractor_user
      end
      
      it "returns the material request with quotes" do
        get "/api/v1/material_requests/#{material_request.id}"
        
        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_key("material_request")
        expect(parsed_response).to have_key("quotes")
        expect(parsed_response["quotes"].length).to eq(2)
      end
    end
  end
  
  describe "POST /api/v1/projects/:project_id/material_requests" do
    let(:contractor_user) { create(:contractor_user) }
    let(:project) { create(:project, contractor: contractor_user.contractor) }
    let(:supplier) { create(:supplier) }
    
    before do
      sign_in contractor_user
    end
    
    let(:valid_attributes) do
      {
        material_request: {
          description: "New Material Request",
          quantity: 100,
          unit: "sqft",
          supplier_ids: [supplier.id]
        }
      }
    end
    
    context "with valid parameters" do
      it "creates a new material request with invited suppliers" do
        expect {
          post "/api/v1/projects/#{project.id}/material_requests", params: valid_attributes
        }.to change(MaterialRequest, :count).by(1)
        .and change(MaterialRequestSupplier, :count).by(1)
        
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)["description"]).to eq("New Material Request")
      end
    end
  end
  
  describe "POST /api/v1/material_requests/:id/invite_suppliers" do
    let(:contractor_user) { create(:contractor_user) }
    let(:project) { create(:project, contractor: contractor_user.contractor) }
    let(:material_request) { create(:material_request, project: project) }
    let(:suppliers) { create_list(:supplier, 2) }
    
    before do
      sign_in contractor_user
    end
    
    it "invites suppliers to the material request" do
      expect {
        post "/api/v1/material_requests/#{material_request.id}/invite_suppliers", 
             params: { supplier_ids: suppliers.map(&:id) }
      }.to change(MaterialRequestSupplier, :count).by(2)
      
      expect(response).to have_http_status(:ok)
      material_request.reload
      expect(material_request.invited_suppliers.count).to eq(2)
    end
  end
  
  describe "DELETE /api/v1/material_requests/:id/remove_supplier/:supplier_id" do
    let(:contractor_user) { create(:contractor_user) }
    let(:project) { create(:project, contractor: contractor_user.contractor) }
    let(:material_request) { create(:material_request, project: project) }
    let(:supplier) { create(:supplier) }
    
    before do
      sign_in contractor_user
      create(:material_request_supplier, material_request: material_request, supplier: supplier)
    end
    
    it "removes a supplier from the material request" do
      expect {
        delete "/api/v1/material_requests/#{material_request.id}/remove_supplier/#{supplier.id}"
      }.to change(MaterialRequestSupplier, :count).by(-1)
      
      expect(response).to have_http_status(:ok)
      material_request.reload
      expect(material_request.invited_suppliers.count).to eq(0)
    end
  end
end