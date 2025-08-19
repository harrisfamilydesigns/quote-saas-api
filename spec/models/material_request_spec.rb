require 'rails_helper'

RSpec.describe MaterialRequest, type: :model do
  describe 'associations' do
    it { should belong_to(:project) }
    it { should have_many(:quotes).dependent(:destroy) }
    it { should have_many(:material_request_suppliers).dependent(:destroy) }
    it { should have_many(:invited_suppliers).through(:material_request_suppliers) }
  end

  describe 'validations' do
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_presence_of(:unit) }
  end

  describe 'supplier invitations' do
    let(:material_request) { create(:material_request) }
    let(:suppliers) { create_list(:supplier, 3) }

    it 'can invite suppliers' do
      suppliers.each do |supplier|
        material_request.material_request_suppliers.create(supplier: supplier)
      end

      expect(material_request.invited_suppliers.count).to eq(3)
      expect(material_request.invited_suppliers).to match_array(suppliers)
    end
  end

  describe 'scopes' do
    let(:supplier) { create(:supplier) }
    let!(:material_request) { create(:material_request) }
    let!(:material_request_supplier) { create(:material_request_supplier, material_request: material_request, supplier: supplier) }

    it 'returns material requests with supplier invites' do
      requests = MaterialRequest.with_supplier_invites(supplier.id)
      expect(requests).to include(material_request)
    end

    it 'does not return material requests without supplier invites' do
      other_material_request = create(:material_request)
      requests = MaterialRequest.with_supplier_invites(supplier.id)
      expect(requests).not_to include(other_material_request)
    end
  end
end
