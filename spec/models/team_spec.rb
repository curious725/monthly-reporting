require 'rails_helper'

RSpec.describe Team do
  it 'has a valid factory' do
    team = FactoryGirl.build(:team)

    expect(team).to be_valid
  end

  describe 'destroys all the records of dependant model' do
    it 'TeamRole' do
      expect(Team.count).to eq(0)
      expect(TeamRole.count).to eq(0)

      team = create(:team, :compact)

      expect(Team.count).to eq(1)
      expect(TeamRole.count).to eq(4)
      expect(team.team_roles.count).to eq(4)

      expect { team.destroy }.not_to raise_exception

      expect(Team.count).to eq(0)
      expect(TeamRole.count).to eq(0)
    end
  end

  context 'as a new bare object' do
    let(:team) { Team.new }

    it { expect(team).not_to be_valid }
  end

  context 'validations' do
    it { should validate_presence_of(:name) }
    it do
      should validate_length_of(:name)
        .is_at_least(3)
        .is_at_most(80)
    end
  end

  context 'associations' do
    it { should have_many(:team_roles) }
    it { should have_many(:users).through(:team_roles) }
  end
end
