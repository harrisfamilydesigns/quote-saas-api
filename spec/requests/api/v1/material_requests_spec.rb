require 'rails_helper'

RSpec.describe "Api::V1::MaterialRequests", type: :request do
  describe "GET /api/v1/projects/:project_id/material_requests" do
    context "as a contractor" do
      let(:contractor_user) { create(:contractor_user) }
      let(:project) { create(:project, contractor: contractor_user.contractor) }
      let!(:material_requests) { create_list(:material_request, 3, project: project) }

      before do
        sign_in contractor_user
      end

      it "returns all material requests for the contractor's project" do
        get "/api/v1/projects/#{project.id}/material_requests"

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_key("material_requests")
        expect(parsed_response["material_requests"].length).to eq(3)
      end
    end

    context "as a supplier" do
      let(:supplier_user) { create(:supplier_user) }
      let(:project) { create(:open_project) }
      let!(:material_requests) { create_list(:material_request, 3, project: project) }
      let!(:other_material_requests) { create_list(:material_request, 2, project: project) }

      before do
        sign_in supplier_user
        # Invite supplier to some material requests
        material_requests.each do |mr|
          create(:material_request_supplier, material_request: mr, supplier: supplier_user.supplier)
        end
      end

      it "returns only material requests the supplier is invited to" do
        get "/api/v1/projects/#{project.id}/material_requests"

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_key("material_requests")
        # Supplier only sees material requests they're invited to
        expect(parsed_response["material_requests"].length).to eq(3)
      end

      it "returns unauthorized for projects they aren't invited to" do
        other_project = create(:project)
        get "/api/v1/projects/#{other_project.id}/material_requests"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/material_requests/:id" do
    let(:contractor_user) { create(:contractor_user) }
    let(:project) { create(:project, contractor: contractor_user.contractor) }
    let(:material_request) { create(:material_request, project: project) }

    context "as the contractor who owns the project" do
      before do
        sign_in contractor_user
      end

      it "returns the material request" do
        get "/api/v1/material_requests/#{material_request.id}"

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_key("material_request")
        expect(parsed_response["material_request"]["id"]).to eq(material_request.id)
      end
    end

    context "as a supplier invited to the material request" do
      let(:supplier_user) { create(:supplier_user) }

      before do
        sign_in supplier_user
        create(:material_request_supplier, material_request: material_request, supplier: supplier_user.supplier)
      end

      it "returns the material request" do
        get "/api/v1/material_requests/#{material_request.id}"

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_key("material_request")
        expect(parsed_response["material_request"]["id"]).to eq(material_request.id)
      end
    end

    context "as a supplier not invited to the material request" do
      let(:supplier_user) { create(:supplier_user) }

      before do
        sign_in supplier_user
      end

      it "returns unauthorized" do
        get "/api/v1/material_requests/#{material_request.id}"

        expect(response).to have_http_status(:unauthorized)
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
          description: "Wood panels",
          quantity: 100,
          unit: "piece",
          supplier_ids: [ supplier.id ]
        }
      }
    end

    context "with valid parameters" do
      it "creates a new material request" do
        expect {
          post "/api/v1/projects/#{project.id}/material_requests", params: valid_attributes
        }.to change(MaterialRequest, :count).by(1)
          .and change(MaterialRequestSupplier, :count).by(1)

        expect(response).to have_http_status(:created)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_key("material_request")
        expect(parsed_response["material_request"]["description"]).to eq("Wood panels")
      end

      it "creates a material request without suppliers" do
        valid_attributes[:material_request].delete(:supplier_ids)
        expect {
          post "/api/v1/projects/#{project.id}/material_requests", params: valid_attributes
        }.to change(MaterialRequest, :count).by(1)
          .and change(MaterialRequestSupplier, :count).by(0)

        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid parameters" do
      it "does not create a new material request" do
        expect {
          post "/api/v1/projects/#{project.id}/material_requests", params: { material_request: { description: "" } }
        }.to change(MaterialRequest, :count).by(0)

        expect(response).to have_http_status(:unprocessable_content)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_key("errors")
      end
    end

    context "as a supplier" do
      let(:supplier_user) { create(:supplier_user) }

      before do
        sign_in supplier_user
      end

      it "returns forbidden" do
        post "/api/v1/projects/#{project.id}/material_requests", params: valid_attributes

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PUT /api/v1/material_requests/:id" do
    let(:contractor_user) { create(:contractor_user) }
    let(:project) { create(:project, contractor: contractor_user.contractor) }
    let(:material_request) { create(:material_request, project: project) }

    before do
      sign_in contractor_user
    end

    context "with valid parameters" do
      let(:new_attributes) do
        {
          material_request: {
            description: "Updated Description",
            quantity: 200,
            unit: "sqft"
          }
        }
      end

      it "updates the material request" do
        put "/api/v1/material_requests/#{material_request.id}", params: new_attributes

        expect(response).to have_http_status(:ok)
        material_request.reload
        expect(material_request.description).to eq("Updated Description")
        expect(material_request.quantity).to eq(200)
        expect(material_request.unit).to eq("sqft")
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity" do
        put "/api/v1/material_requests/#{material_request.id}", params: { material_request: { quantity: -1 } }

        expect(response).to have_http_status(:unprocessable_content)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_key("errors")
      end
    end

    context "as a supplier" do
      let(:supplier_user) { create(:supplier_user) }

      before do
        sign_in supplier_user
      end

      it "returns forbidden" do
        put "/api/v1/material_requests/#{material_request.id}", params: { material_request: { description: "Test" } }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE /api/v1/material_requests/:id" do
    let(:contractor_user) { create(:contractor_user) }
    let(:project) { create(:project, contractor: contractor_user.contractor) }
    let!(:material_request) { create(:material_request, project: project) }

    before do
      sign_in contractor_user
    end

    it "deletes the material request" do
      expect {
        delete "/api/v1/material_requests/#{material_request.id}"
      }.to change(MaterialRequest, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    context "as a supplier" do
      let(:supplier_user) { create(:supplier_user) }

      before do
        sign_in supplier_user
      end

      it "returns forbidden" do
        expect {
          delete "/api/v1/material_requests/#{material_request.id}"
        }.not_to change(MaterialRequest, :count)

        expect(response).to have_http_status(:forbidden)
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
        post "/api/v1/material_requests/#{material_request.id}/invite_suppliers", params: { supplier_ids: suppliers.map(&:id) }
      }.to change(MaterialRequestSupplier, :count).by(2)

      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to have_key("material_request")
    end

    it "doesn't duplicate invitations" do
      # First create one invitation
      create(:material_request_supplier, material_request: material_request, supplier: suppliers.first)

      expect {
        post "/api/v1/material_requests/#{material_request.id}/invite_suppliers", params: { supplier_ids: suppliers.map(&:id) }
      }.to change(MaterialRequestSupplier, :count).by(1)

      expect(response).to have_http_status(:ok)
    end

    context "as a supplier" do
      let(:supplier_user) { create(:supplier_user) }

      before do
        sign_in supplier_user
      end

      it "returns forbidden" do
        post "/api/v1/material_requests/#{material_request.id}/invite_suppliers", params: { supplier_ids: [ suppliers.first.id ] }

        expect(response).to have_http_status(:forbidden)
      end
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
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to have_key("material_request")
    end

    context "as a supplier" do
      let(:supplier_user) { create(:supplier_user) }

      before do
        sign_in supplier_user
      end

      it "returns forbidden" do
        delete "/api/v1/material_requests/#{material_request.id}/remove_supplier/#{supplier.id}"

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
