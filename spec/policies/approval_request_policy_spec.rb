require 'rails_helper'

describe ApprovalRequestPolicy do
  let(:team) do
    create :team, :with_users, number_of_members: 1, number_of_managers: 2
  end

  let(:second_manager) { team.team_roles.managers.second.user }
  let(:manager) { team.team_roles.managers.first.user }
  let(:member)  { team.team_roles.members.first.user }
  let(:guest)   { team.team_roles.guests.first.user }
  let(:approval_request) { manager.approval_requests.first }
  let(:not_own_approval_request) do
    second_manager.approval_requests.first
  end

  let(:create_vacation_request) do
    create :vacation_request, :with_approval_requests, user: member
  end

  before { create_vacation_request }

  subject { ApprovalRequestPolicy }

  permissions :accept?, :decline? do
    context 'for a team-mate user' do
      context 'with role=manager' do
        context 'who owns the approval request' do
          it 'grants access' do
            expect(subject).to permit(manager, approval_request)
          end
        end

        context 'who does not own the approval request' do
          it 'denies access' do
            expect(subject).not_to permit(manager, not_own_approval_request)
          end
        end
      end

      context 'with role=member' do
        it 'denies access' do
          expect(subject).not_to permit(member, approval_request)
        end
      end

      context 'with role=guest' do
        it 'denies access' do
          expect(subject).not_to permit(guest, approval_request)
        end
      end
    end

    context 'for not a team-mate user' do
      let(:another_team) do
        create :team, :with_users, number_of_members: 1
      end
      let(:approval_request) do
        ApprovalRequest.create vacation_request_id: create_vacation_request.id,
                               manager_id: another_manager.id
      end
      let(:another_manager) { another_team.team_roles.managers.first.user }
      let(:another_member)  { another_team.team_roles.members.first.user }
      let(:another_guest)   { another_team.team_roles.guests.first.user }

      context 'with role=manager' do
        context 'who owns the approval request' do
          it 'denies access' do
            expect(subject).not_to permit(another_manager, approval_request)
          end
        end

        context 'who does not own the approval request' do
          it 'denies access' do
            expect(subject)
              .not_to permit(another_manager, not_own_approval_request)
          end
        end
      end

      context 'with role=member' do
        it 'denies access' do
          expect(subject).not_to permit(another_member, approval_request)
        end
      end

      context 'with role=guest' do
        it 'denies access' do
          expect(subject).not_to permit(another_guest, approval_request)
        end
      end
    end
  end
end
