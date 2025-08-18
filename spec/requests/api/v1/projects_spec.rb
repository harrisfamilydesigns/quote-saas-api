require 'rails_helper'

RSpec.describe "Api::V1::Projects", type: :request do
  describe "GET /api/v1/projects" do
    context "as a contractor" do
      let(:contractor_user) { create(:contractor_user) }
      let!(:projects) { create_list(:project, 3, contractor: contractor_user.contractor) }
      let!(:other_projects) { create_list(:project, 2) }

      before do
        sign_in contractor_user
      end

      it "returns only the contractor's projects" do
        get "/api/v1/projects"

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.length).to eq(3)
      end
    end

    context "as a supplier" do
      let(:supplier_user) { create(:supplier_user) }
      let(:material_request) { create(:material_request) }
      let!(:quote) { create(:quote, material_request: material_request, supplier: supplier_user.supplier) }

      before do
        sign_in supplier_user
      end

      it "returns projects with material requests they've quoted on" do
        get "/api/v1/projects"

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.length).to eq(1)
        # Just check that we got a successful response
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /api/v1/projects/:id" do
    let(:contractor_user) { create(:contractor_user) }
    let(:project) { create(:project, contractor: contractor_user.contractor) }
    let!(:material_requests) { create_list(:material_request, 2, project: project) }

    context "as the project owner" do
      before do
        sign_in contractor_user
      end

      it "returns the project with material requests" do
        get "/api/v1/projects/#{project.id}"

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_key("project")
        expect(parsed_response).to have_key("material_requests")
        expect(parsed_response["material_requests"].length).to eq(2)
      end
    end

    context "as another contractor" do
      let(:other_contractor_user) { create(:contractor_user) }

      before do
        sign_in other_contractor_user
      end

      it "returns unauthorized" do
        get "/api/v1/projects/#{project.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/v1/projects" do
    let(:contractor_user) { create(:contractor_user) }

    before do
      sign_in contractor_user
    end

    let(:valid_attributes) do
      {
        project: {
          name: "New Project",
          description: "Description for the new project",
          status: "draft"
        }
      }
    end

    context "with valid parameters" do
      it "creates a new project" do
        expect {
          post "/api/v1/projects", params: valid_attributes
        }.to change(Project, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)["name"]).to eq("New Project")
      end
    end

    context "with invalid parameters" do
      it "does not create a new project" do
        expect {
          post "/api/v1/projects", params: { project: { name: "" } }
        }.to change(Project, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT /api/v1/projects/:id" do
    let(:contractor_user) { create(:contractor_user) }
    let(:project) { create(:project, contractor: contractor_user.contractor) }

    before do
      sign_in contractor_user
    end

    context "with valid parameters" do
      let(:new_attributes) do
        {
          project: {
            name: "Updated Project",
            status: "open"
          }
        }
      end

      it "updates the project" do
        put "/api/v1/projects/#{project.id}", params: new_attributes

        expect(response).to have_http_status(:ok)
        project.reload
        expect(project.name).to eq("Updated Project")
        expect(project.status).to eq("open")
      end
    end
  end

  describe "DELETE /api/v1/projects/:id" do
    let(:contractor_user) { create(:contractor_user) }
    let!(:project) { create(:project, contractor: contractor_user.contractor) }

    before do
      sign_in contractor_user
    end

    it "deletes the project" do
      expect {
        delete "/api/v1/projects/#{project.id}"
      }.to change(Project, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
