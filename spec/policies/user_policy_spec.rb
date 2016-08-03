require 'rails_helper'

RSpec.describe UserPolicy do
  let(:team) { create(:team, :compact) }
  let(:simple_user) { create(:user) }

  let(:admin)   { team.team_roles.admins.first.user }
  let(:manager) { team.team_roles.managers.first.user }
  let(:member)  { team.team_roles.members.first.user }
  let(:guest)   { team.team_roles.guests.first.user }

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

  subject { UserPolicy }

  permissions :index?,
              :approval_requests?,
              :available_vacations?,
              :requested_vacations? do
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

    context 'for user with no roles' do
      let(:user) { simple_user }
      it_behaves_like 'a good boy'
    end
  end

  permissions :create?, :update?, :destroy?, :invite? do
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

    context 'for user with no roles' do
      let(:user) { simple_user }
      it_behaves_like 'a good guard'
    end
  end

  permissions :approval_requests? do
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

    context 'for user with no roles' do
      let(:user) { simple_user }
      it_behaves_like 'a good boy'
    end
  end
end
