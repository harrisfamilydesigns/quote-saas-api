require 'rails_helper'

RSpec.describe "Api::V1::Auth", type: :request do
  describe "POST /api/v1/auth/register" do
    let(:contractor) { create(:contractor) }
    
    let(:valid_attributes) do
      {
        user: {
          email: "test@example.com",
          password: "password",
          role: "contractor",
          contractor_id: contractor.id
        }
      }
    end
    
    context "with valid parameters" do
      it "creates a new user" do
        expect {
          post "/api/v1/auth/register", params: valid_attributes
        }.to change(User, :count).by(1)
        
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include("message", "user")
      end
    end
    
    context "with invalid parameters" do
      it "does not create a new user" do
        expect {
          post "/api/v1/auth/register", params: { user: { email: "" } }
        }.to change(User, :count).by(0)
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("errors")
      end
    end
  end
  
  describe "POST /api/v1/auth/login" do
    let(:user) { create(:contractor_user) }
    
    context "with valid credentials" do
      it "logs in the user and returns a token" do
        post "/api/v1/auth/login", params: {
          user: {
            email: user.email,
            password: "password"
          }
        }
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include("message", "user")
        expect(response.headers).to include("Authorization")
      end
    end
    
    context "with invalid credentials" do
      it "returns an error" do
        post "/api/v1/auth/login", params: {
          user: {
            email: user.email,
            password: "wrong_password"
          }
        }
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include("error")
      end
    end
  end
  
  describe "DELETE /api/v1/auth/logout" do
    let(:user) { create(:contractor_user) }
    
    before do
      sign_in user
    end
    
    it "logs out the user" do
      delete "/api/v1/auth/logout"
      
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include("message")
    end
  end
  
  describe "GET /api/v1/auth/me" do
    let(:user) { create(:contractor_user) }
    
    context "when authenticated" do
      before do
        sign_in user
      end
      
      it "returns the current user" do
        get "/api/v1/auth/me"
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include("user")
        # Check that we get a successful response with user data
        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_key("user")
      end
    end
    
    context "when not authenticated" do
      it "returns an error" do
        get "/api/v1/auth/me"
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end