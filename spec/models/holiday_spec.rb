require 'rails_helper'

RSpec.describe Holiday do
  it 'has a valid factory' do
    holiday = FactoryGirl.build(:holiday)

    expect(holiday).to be_valid
  end

  context 'as a brand new object' do
    let(:holiday) { Holiday.new }

    it { expect(holiday).to have_attributes description: nil }
    it { expect(holiday).to have_attributes duration: nil }
    it { expect(holiday).to have_attributes start: nil }

    it { expect(holiday).not_to be_valid }
  end

  context 'validations' do
    it { should validate_presence_of(:description) }
    it { should validate_uniqueness_of(:description).case_insensitive }
    it do
      should validate_length_of(:description)
        .is_at_least(7)
        .is_at_most(25)
    end

    it { should validate_presence_of(:duration) }
    it do
      should validate_numericality_of(:duration)
        .only_integer
        .is_greater_than(0)
        .is_less_than(5)
    end

    it { should validate_presence_of(:start) }
    it do
      should validate_inclusion_of(:start)
        .in_range(Date.new(2013, 9, 1)..Date.new(2050, 1, 1))
    end
  end
end
