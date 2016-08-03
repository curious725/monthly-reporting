require 'rails_helper'

RSpec.shared_examples 'request with conflict' do
  it 'should respond with status code :conflict (409)' do
    send_request
    expect(response).to have_http_status(:conflict)
  end

  it 'should not remove approval request from DB' do
    expect { send_request }.not_to change(ApprovalRequest, :count)
  end

  it 'should not change vacation request status' do
    id = approval_request.vacation_request_id

    expect { send_request }
      .not_to change { VacationRequest.find_by(id: id).status }
  end
end

RSpec.describe ApprovalRequestsController do
  let(:team) { create :team, :with_users, number_of_members: 1 }
  let(:manager) { team.team_roles.managers.first.user }
  let(:member)  { team.team_roles.members.first.user }
  let(:guest)   { team.team_roles.guests.first.user }
  let(:user)    { manager }
  let(:approval_request) { manager.approval_requests.first }
  let(:create_vacation_request) do
    create :vacation_request, :with_approval_requests, user: member
  end

  before { create_vacation_request }

  ################################################################## GET #accept
  describe 'GET #accept' do
    let(:send_request) { get :accept, params }
    let(:params) { Hash[format: :json, id: approval_request.id] }

    context 'from authenticated user with manager role' do
      before { sign_in user }

      context 'with ID of not existing approval request' do
        let(:params) { Hash[format: :json, id: (approval_request.id - 1)] }

        it 'should respond with status code :not_found (404)' do
          send_request
          expect(response).to have_http_status(:not_found)
        end

        it 'should not remove approval request from DB' do
          expect { send_request }.not_to change(ApprovalRequest, :count)
        end

        it 'should not change vacation request status' do
          id = approval_request.vacation_request_id

          expect { send_request }
            .not_to change { VacationRequest.find_by(id: id).status }
        end
      end

      context 'when vacation request status is set to "accepted"' do
        before do
          vacation_request = approval_request.vacation_request
          vacation_request.status = VacationRequest.statuses[:accepted]
          vacation_request.save
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "declined"' do
        before do
          vacation_request = approval_request.vacation_request
          vacation_request.status = VacationRequest.statuses[:declined]
          vacation_request.save
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "cancelled"' do
        before do
          vacation_request = approval_request.vacation_request
          vacation_request.status = VacationRequest.statuses[:cancelled]
          vacation_request.save
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "inprogress"' do
        before do
          vacation_request = approval_request.vacation_request
          vacation_request.status = VacationRequest.statuses[:inprogress]
          vacation_request.save
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "used"' do
        before do
          vacation_request = approval_request.vacation_request
          vacation_request.status = VacationRequest.statuses[:used]
          vacation_request.save
        end

        it_should_behave_like 'request with conflict'
      end

      context 'without another user with manager role in the team' do
        it 'should respond with status code :ok (200)' do
          send_request
          expect(response).to have_http_status(:ok)
        end

        it 'should remove approval request from DB' do
          expect { send_request }.to change(ApprovalRequest, :count).by(-1)
        end

        it 'should set vacation request status to "accepted"' do
          id = approval_request.vacation_request_id

          expect { send_request }
            .to change { VacationRequest.find_by(id: id).status }
            .from('requested').to('accepted')
        end
      end

      context 'with another user with manager role in the team' do
        let(:team) do
          create :team, :with_users, number_of_members: 1, number_of_managers: 2
        end

        context 'who has not yet responded to the approval request' do
          it 'should respond with status code :ok (200)' do
            send_request
            expect(response).to have_http_status(:ok)
          end

          it 'should remove approval request from DB' do
            expect { send_request }.to change(ApprovalRequest, :count).by(-1)
          end

          it 'should not change vacation request status' do
            id = approval_request.vacation_request_id

            expect { send_request }
              .not_to change { VacationRequest.find_by(id: id).status }
          end
        end

        context 'who has already accepted the approval request' do
          let(:another_manager) { team.team_roles.managers.second.user }

          before do
            another_manager.approval_requests.first.destroy
          end

          it 'should respond with status code :ok (200)' do
            send_request
            expect(response).to have_http_status(:ok)
          end

          it 'should remove approval request from DB' do
            expect { send_request }.to change(ApprovalRequest, :count).by(-1)
          end

          it 'should set vacation request status to "accepted"' do
            id = approval_request.vacation_request_id

            expect { send_request }
              .to change { VacationRequest.find_by(id: id).status }
              .from('requested').to('accepted')
          end
        end
      end
    end

    context 'from authenticated unauthorized user' do
      before { sign_in member }

      it_should_behave_like 'unauthorized request'

      it 'should not delete approval request from DB' do
        expect { send_request }.not_to change(ApprovalRequest, :count)
      end
    end

    context 'from unauthenticated user' do
      it_should_behave_like 'unauthenticated request'

      it 'should not delete approval request from DB' do
        expect { send_request }.not_to change(ApprovalRequest, :count)
      end
    end
  end

  ################################################################# GET #decline
  describe 'GET #decline' do
    let(:send_request) { get :decline, params }
    let(:params) { Hash[format: :json, id: approval_request.id] }

    context 'from authenticated user with manager role' do
      before { sign_in user }

      context 'with ID of not existing approval request' do
        let(:params) { Hash[format: :json, id: (approval_request.id - 1)] }

        it 'should respond with status code :not_found (404)' do
          send_request
          expect(response).to have_http_status(:not_found)
        end

        it 'should not remove approval request from DB' do
          expect { send_request }.not_to change(ApprovalRequest, :count)
        end

        it 'should not change vacation request status' do
          id = approval_request.vacation_request_id

          expect { send_request }
            .not_to change { VacationRequest.find_by(id: id).status }
        end
      end

      context 'when vacation request status is set to "accepted"' do
        before do
          vacation_request = approval_request.vacation_request
          vacation_request.status = VacationRequest.statuses[:accepted]
          vacation_request.save
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "declined"' do
        before do
          vacation_request = approval_request.vacation_request
          vacation_request.status = VacationRequest.statuses[:declined]
          vacation_request.save
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "cancelled"' do
        before do
          vacation_request = approval_request.vacation_request
          vacation_request.status = VacationRequest.statuses[:cancelled]
          vacation_request.save
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "inprogress"' do
        before do
          vacation_request = approval_request.vacation_request
          vacation_request.status = VacationRequest.statuses[:inprogress]
          vacation_request.save
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "used"' do
        before do
          vacation_request = approval_request.vacation_request
          vacation_request.status = VacationRequest.statuses[:used]
          vacation_request.save
        end

        it_should_behave_like 'request with conflict'
      end

      context 'without another user with manager role in the team' do
        it 'should respond with status code :ok (200)' do
          send_request
          expect(response).to have_http_status(:ok)
        end

        it 'should remove approval request from DB' do
          expect { send_request }.to change(ApprovalRequest, :count).by(-1)
        end

        it 'should set vacation request status to "declined"' do
          id = approval_request.vacation_request_id

          expect { send_request }
            .to change { VacationRequest.find_by(id: id).status }
            .from('requested').to('declined')
        end
      end

      context 'with another user with manager role in the team' do
        let(:team) do
          create :team, :with_users, number_of_members: 1, number_of_managers: 2
        end

        context 'who has not yet responded to the approval request' do
          it 'should respond with status code :ok (200)' do
            send_request
            expect(response).to have_http_status(:ok)
          end

          it 'should remove all associated approval requests from DB' do
            expect { send_request }.to change(ApprovalRequest, :count).by(-2)
          end

          it 'should set vacation request status to "declined"' do
            id = approval_request.vacation_request_id

            expect { send_request }
              .to change { VacationRequest.find_by(id: id).status }
              .from('requested').to('declined')
          end
        end

        context 'who has already accepted the approval request' do
          let(:another_manager) { team.team_roles.managers.second.user }

          before do
            another_manager.approval_requests.first.destroy
          end

          it 'should respond with status code :ok (200)' do
            send_request
            expect(response).to have_http_status(:ok)
          end

          it 'should remove approval request from DB' do
            expect { send_request }.to change(ApprovalRequest, :count).by(-1)
          end

          it 'should set vacation request status to "declined"' do
            id = approval_request.vacation_request_id

            expect { send_request }
              .to change { VacationRequest.find_by(id: id).status }
              .from('requested').to('declined')
          end
        end
      end
    end

    context 'from authenticated unauthorized user' do
      before { sign_in member }

      it_should_behave_like 'unauthorized request'

      it 'should not delete approval request from DB' do
        expect { send_request }.not_to change(ApprovalRequest, :count)
      end
    end

    context 'from unauthenticated user' do
      it_should_behave_like 'unauthenticated request'

      it 'should not delete approval request from DB' do
        expect { send_request }.not_to change(ApprovalRequest, :count)
      end
    end
  end
end
