require 'rails_helper'

RSpec.describe AvailableVacation do
  let(:user) { FactoryGirl.create(:user) }

  it 'has a valid factory' do
    available_vacation = FactoryGirl.build(:available_vacation)

    expect(available_vacation).to be_valid
  end

  it 'allows to pass "available_days" as a float number, like 1.5' do
    available_vacation = FactoryGirl.build(:available_vacation,
                                           available_days: 1.5)

    expect(available_vacation).to be_valid
  end

  it 'does not allow to pass "available_days" equal to 0' do
    available_vacation = FactoryGirl.build(:available_vacation,
                                           available_days: 0)

    expect(available_vacation).not_to be_valid
  end

  describe '.accumulate_more_days' do
    let(:available_vacation) { create(:available_vacation) }

    context 'when the record is up-to-date' do
      it 'does not update the record' do
        av_id = available_vacation.id
        expect { available_vacation.accumulate_more_days }
          .not_to change { AvailableVacation.find_by!(av_id).available_days }
      end
    end

    context 'when the record is not up-to-date' do
      before do
        available_vacation.updated_at = Time.zone.now - 1.day
      end

      it 'updates the record' do
        av_id = available_vacation.id
        days = available_vacation.available_days
        expected = days + AvailableVacations::RATES[:planned]
        expect { available_vacation.accumulate_more_days }
          .to change { AvailableVacation.find_by!(av_id).available_days }
          .to(expected.round(5))
      end
    end
  end

  context 'as a brand new object' do
    let(:available_vacation) { AvailableVacation.new }

    it { expect(available_vacation).to have_attributes available_days: nil }
    it { expect(available_vacation).to have_attributes kind: 'planned' }
    it { expect(available_vacation).to have_attributes user_id: nil }

    it { expect(available_vacation).not_to be_valid }
  end

  context 'having record with particular pair of user and vacation type' do
    describe 'on attempt to add record with the same pair of user and type' do
      before do
        FactoryGirl.create(:available_vacation, user_id: user.id)
      end

      it 'should raise exception' do
        expect { FactoryGirl.create(:available_vacation, user_id: user.id) }
          .to raise_exception(ActiveRecord::RecordInvalid)
          .with_message(/User already has this type of limit/)
      end
    end
  end

  context 'validations' do
    it { should define_enum_for(:kind) }

    it { should validate_presence_of(:available_days) }
    it { should validate_presence_of(:kind) }
    it { should validate_presence_of(:user_id) }
  end

  context 'associations' do
    it { should belong_to(:user) }
  end
end
