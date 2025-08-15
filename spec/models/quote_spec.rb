require 'rails_helper'

RSpec.describe Quote, type: :model do
  describe 'associations' do
    it { should belong_to(:material_request) }
    it { should belong_to(:supplier) }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than(0) }
    it { should validate_presence_of(:lead_time_days) }
    it { should validate_numericality_of(:lead_time_days).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(Quote::STATUSES) }
  end
  
  describe 'defaults' do
    it 'has a default status of pending' do
      quote = Quote.new
      expect(quote.status).to eq('pending')
    end
  end
end