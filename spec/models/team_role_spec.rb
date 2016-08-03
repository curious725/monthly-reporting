require 'rails_helper'

RSpec.describe TeamRole do
  it 'has a valid factory' do
    team_role = build(:team_role)
    expect(team_role).to be_valid
  end

  context 'as a new bare object' do
    let(:team_role) { TeamRole.new }

    it { expect(team_role).to have_attributes role: 'guest' }
    it { expect(team_role).to have_attributes user_id: nil }
    it { expect(team_role).to have_attributes team_id: nil }

    it { expect(team_role).not_to be_valid }
  end

  context 'as a new valid object' do
    let(:team_role) { build(:team_role) }

    it { expect(team_role).to     have_attributes role: 'member' }
    it { expect(team_role).not_to have_attributes user_id: nil }
    it { expect(team_role).not_to have_attributes team_id: nil }

    it { expect(team_role).to be_valid }
  end

  it 'does not allow records with duplicate role, team_id, and user_id' do
    team = create(:team)
    user = create(:user)
    create(:team_role, team: team, user: user, role: 'member')

    expect { create(:team_role, team: team, user: user, role: 'member') }
      .to raise_exception(ActiveRecord::RecordInvalid)
  end

  describe '.managers' do
    let(:team) { create(:team, :with_users, number_of_managers: 1) }

    it 'provides list of users with "manager" role' do
      expect(TeamRole).to respond_to(:managers)
      expect(team.team_roles.managers.count).to eq(1)
    end
  end

  describe '.members' do
    let(:team) { create(:team, :with_users, number_of_members: 1) }

    it 'provides list of users with "member" role' do
      expect(TeamRole).to respond_to(:members)
      expect(team.team_roles.members.count).to eq(1)
    end
  end

  describe '.guests' do
    let(:team) { create(:team, :with_users, number_of_guests: 1) }

    it 'provides list of users with "guest" role' do
      expect(TeamRole).to respond_to(:guests)
      expect(team.team_roles.guests.count).to eq(1)
    end
  end

  context 'validations' do
    it { should define_enum_for(:role) }

    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:team_id) }
  end

  context 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:team) }
  end
end
