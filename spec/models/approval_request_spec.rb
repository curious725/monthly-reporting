require 'rails_helper'

RSpec.describe ApprovalRequest do
  let(:manager) { FactoryGirl.create(:user, email: 'custom@i.ua') }
  let(:vacation_request) { FactoryGirl.create(:vacation_request) }

  context 'with proper parameters' do
    it do
      request = ApprovalRequest.new(manager_id: manager.id,
                                    vacation_request_id: vacation_request.id)
      expect(request).to be_valid
    end
  end

  it 'does not allow records with duplicate vacation_request_id and user_id' do
    ApprovalRequest.create(manager_id: manager.id,
                           vacation_request_id: vacation_request.id)

    expect do
      ApprovalRequest.create!(manager_id: manager.id,
                              vacation_request_id: vacation_request.id)
    end.to raise_exception(ActiveRecord::RecordInvalid)
  end

  context 'as a new bare object' do
    let(:approval_request) { ApprovalRequest.new }

    it { expect(approval_request).to have_attributes manager_id: nil }
    it { expect(approval_request).to have_attributes vacation_request_id: nil }

    it { expect(approval_request).not_to be_valid }
  end

  context 'validations' do
    it { should validate_presence_of(:vacation_request_id) }
    it { should validate_presence_of(:manager_id) }
  end

  context 'associations' do
    it { should belong_to(:vacation_request) }
    it { should belong_to(:user) }
  end
end
