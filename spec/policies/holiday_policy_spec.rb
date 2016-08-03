require 'rails_helper'

describe HolidayPolicy do
  let(:team) { create(:team, :compact) }
  let(:holiday) { create(:holiday) }

  subject { HolidayPolicy }

  permissions :create?, :update?, :destroy? do
    let(:admin)   { team.team_roles.admins.first.user }
    let(:manager) { team.team_roles.managers.first.user }
    let(:member)  { team.team_roles.members.first.user }
    let(:guest)   { team.team_roles.guests.first.user }

    context 'for user with role=admin' do
      it 'grants access' do
        expect(subject).to permit(admin, holiday)
      end
    end

    context 'for user with role=manager' do
      it 'denies access' do
        expect(subject).not_to permit(manager, holiday)
      end
    end

    context 'for user with role=member' do
      it 'denies access' do
        expect(subject).not_to permit(member, holiday)
      end
    end

    context 'for user with role=guest' do
      it 'denies access' do
        expect(subject).not_to permit(guest, holiday)
      end
    end
  end
end
