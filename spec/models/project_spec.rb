require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'associations' do
    it { should belong_to(:contractor) }
    it { should have_many(:material_requests).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(Project::STATUSES) }
  end

  describe 'defaults' do
    it 'has a default status of draft' do
      project = Project.new
      expect(project.status).to eq('draft')
    end
  end

  describe 'scopes' do
    let(:supplier) { create(:supplier) }
    let!(:project_with_invite) { create(:project) }
    let!(:material_request) { create(:material_request, project: project_with_invite) }
    let!(:material_request_supplier) { create(:material_request_supplier, material_request: material_request, supplier: supplier) }
    let!(:project_without_invite) { create(:project) }

    it 'returns projects with material request supplier invites' do
      projects = Project.with_material_request_supplier_invites(supplier.id)
      expect(projects).to include(project_with_invite)
      expect(projects).not_to include(project_without_invite)
    end
  end
end
