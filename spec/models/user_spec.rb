require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should belong_to(:contractor).optional }
    it { should belong_to(:supplier).optional }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:role) }
    it { should validate_inclusion_of(:role).in_array(User::ROLES) }
  end
  
  describe 'user roles' do
    let(:contractor_user) { create(:contractor_user) }
    let(:supplier_user) { create(:supplier_user) }
    let(:admin_user) { create(:admin_user) }
    
    describe '#contractor_user?' do
      it 'returns true for contractor users' do
        expect(contractor_user.contractor_user?).to be true
      end
      
      it 'returns false for non-contractor users' do
        expect(supplier_user.contractor_user?).to be false
        expect(admin_user.contractor_user?).to be false
      end
    end
    
    describe '#supplier_user?' do
      it 'returns true for supplier users' do
        expect(supplier_user.supplier_user?).to be true
      end
      
      it 'returns false for non-supplier users' do
        expect(contractor_user.supplier_user?).to be false
        expect(admin_user.supplier_user?).to be false
      end
    end
    
    describe '#admin_user?' do
      it 'returns true for admin users' do
        expect(admin_user.admin_user?).to be true
      end
      
      it 'returns false for non-admin users' do
        expect(contractor_user.admin_user?).to be false
        expect(supplier_user.admin_user?).to be false
      end
    end
  end
end