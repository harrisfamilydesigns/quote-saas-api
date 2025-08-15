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
end