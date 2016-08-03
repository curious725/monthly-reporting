require 'rails_helper'

describe TeamPolicy do
  let(:team)    { create(:team, :compact) }
  let(:admin)   { team.team_roles.admins.first.user }
  let(:manager) { team.team_roles.managers.first.user }
  let(:member)  { team.team_roles.members.first.user }
  let(:guest)   { team.team_roles.guests.first.user }
  let(:unregistred) { nil }

  shared_examples 'a good boy' do
    it 'and grants access' do
      expect(subject).to permit(user)
    end
  end

  shared_examples 'a good guard' do
    it 'and denies access' do
      expect(subject).not_to permit(user)
    end
  end

  subject { TeamPolicy }

  permissions :index? do
    context 'for user with role=admin' do
      let(:user) { admin }
      it_behaves_like 'a good boy'
    end

    context 'for user with role=manager' do
      let(:user) { manager }
      it_behaves_like 'a good boy'
    end

    context 'for user with role=member' do
      let(:user) { member }
      it_behaves_like 'a good boy'
    end

    context 'for user with role=guest' do
      let(:user) { guest }
      it_behaves_like 'a good boy'
    end

    context 'for not registered user' do
      let(:user) { unregistred }
      it_behaves_like 'a good guard'
    end
  end

  permissions :create?, :update?, :destroy? do
    context 'for user with role=admin' do
      let(:user) { admin }
      it_behaves_like 'a good boy'
    end

    context 'for user with role=manager' do
      let(:user) { manager }
      it_behaves_like 'a good guard'
    end

    context 'for user with role=member' do
      let(:user) { member }
      it_behaves_like 'a good guard'
    end

    context 'for user with role=guest' do
      let(:user) { guest }
      it_behaves_like 'a good guard'
    end

    context 'for not registered user' do
      let(:user) { unregistred }
      it_behaves_like 'a good guard'
    end
  end
end
