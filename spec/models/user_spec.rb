require 'rails_helper'

RSpec.describe User do
  it 'has a valid factory' do
    record = FactoryGirl.build(:user)

    expect(record).to be_valid
  end

  context 'validations' do
    it { should validate_presence_of(:employment_date) }
    it do
      should validate_inclusion_of(:birth_date)
        .in_range(Date.new(1900, 1, 1)..Date.new(2050, 1, 1))
    end
    it do
      should validate_inclusion_of(:employment_date)
        .in_range(Date.new(2013, 01, 01)..Date.new(2050, 1, 1))
    end
  end

  describe 'destroys all the records of dependant model' do
    let(:team) { create(:team, :compact) }
    let(:another_team) { create(:team) }
    let(:manager) { team.team_roles.managers.first.user }
    let(:member) { team.team_roles.members.first.user }
    let(:user) { member }

    context 'TeamRole' do
      let(:number_of_roles) { TeamRole.roles.count }

      before do
        expect(User.count).to eq(0)
        expect(Team.count).to eq(0)
        expect(TeamRole.count).to eq(0)

        expect(team.team_roles.count).to eq(number_of_roles)
        expect(user.team_roles.count).to eq(1)

        create(:team_role, team: another_team, user: user)

        expect(User.count).to eq(number_of_roles)
        expect(Team.count).to eq(2)
        expect(TeamRole.count).to eq(number_of_roles + 1)
      end

      it 'successfully' do
        expect { user.destroy }.not_to raise_exception

        expect(User.count).to eq(number_of_roles - 1)
        expect(Team.count).to eq(2)
        expect(TeamRole.count).to eq(number_of_roles - 1)
      end
    end

    context 'VacationRequest' do
      let(:number_of_roles) { TeamRole.roles.count }

      before do
        expect(User.count).to eq(0)
        expect(VacationRequest.count).to eq(0)
        expect(ApprovalRequest.count).to eq(0)

        expect(team.team_roles.count).to eq(number_of_roles)
        expect(user.team_roles.count).to eq(1)

        create(:vacation_request, user: user)

        expect(User.count).to eq(number_of_roles)
        expect(VacationRequest.count).to eq(1)
      end

      it 'successfully' do
        expect { user.destroy }.not_to raise_exception

        expect(User.count).to eq(number_of_roles - 1)
        expect(VacationRequest.count).to eq(0)
      end
    end

    context 'AvailableVacation' do
      let(:user) { create(:user, :with_available_vacations) }

      before do
        expect(User.count).to eq(0)
        expect(AvailableVacation.count).to eq(0)

        expect(user.available_vacations.count).to eq(3)

        expect(User.count).to eq(1)
        expect(AvailableVacation.count).to eq(3)
      end

      it 'successfully' do
        expect { user.destroy }.not_to raise_exception

        expect(User.count).to eq(0)
        expect(AvailableVacation.count).to eq(0)
      end
    end

    context 'ApprovalRequest' do
      let(:number_of_roles) { TeamRole.roles.count }

      before do
        expect(User.count).to eq(0)
        expect(ApprovalRequest.count).to eq(0)
        expect(VacationRequest.count).to eq(0)

        vacation = create(:vacation_request, user: user)
        ApprovalRequest.create(user: manager, vacation_request: vacation)

        expect(User.count).to eq(number_of_roles)
        expect(ApprovalRequest.count).to eq(1)
        expect(VacationRequest.count).to eq(1)
      end

      it 'successfully' do
        expect { manager.destroy }.not_to raise_exception

        expect(User.count).to eq(number_of_roles - 1)
        expect(ApprovalRequest.count).to eq(0)
        expect(VacationRequest.count).to eq(1)
      end
    end
  end
end
