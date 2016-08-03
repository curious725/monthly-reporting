require 'rails_helper'

RSpec.describe VacationRequestsController do
  let(:team) { create :team, :with_users, number_of_members: 1 }
  let(:manager) { team.team_roles.managers.first.user }
  let(:member)  { team.team_roles.members.first.user }
  let(:guest)   { team.team_roles.guests.first.user }
  let(:user)    { manager }
  let(:vacation) { create(:vacation_request, user: user) }

  shared_examples 'request with conflict' do
    it 'should respond with status code :conflict (409)' do
      send_request
      expect(response).to have_http_status(:conflict)
    end

    it 'should not change vacation request status' do
      vr = vacation
      expect { send_request }
        .not_to change { VacationRequest.find_by(id: vr.id).status }
    end
  end

  shared_examples 'pretty approvers request' do
    it 'should respond with status code :ok (200)' do
      send_request
      expect(response).to have_http_status(:ok)
    end

    it 'should respond with proper JSON data structure' do
      send_request
      expected = %w(id first_name last_name)
      expect(response.body).to have_json_attributes(expected)
    end
  end

  shared_examples 'pretty cancel request' do
    it 'should respond with status code :ok (200)' do
      send_request
      expect(response).to have_http_status(:ok)
    end

    it 'should set vacation request status to "cancelled"' do
      expect { send_request }
        .to change { VacationRequest.find_by(id: vacation.id).status }
        .to('cancelled')
    end
  end

  shared_examples 'pretty finish request' do
    it 'should respond with status code :ok (200)' do
      send_request
      expect(response).to have_http_status(:ok)
    end

    it 'should set vacation request status to "used"' do
      expect { send_request }
        .to change { VacationRequest.find_by(id: vacation.id).status }
        .to('used')
    end

    it 'should properly update available vacations of the user' do
      av_id = user.available_vacations.planned.first.id
      expect { send_request }
        .to change { AvailableVacation.find_by(id: av_id).available_days.to_i }
        .by(-vacation.duration(Holiday.dates))
    end
  end

  shared_examples 'pretty start request' do
    it 'should respond with status code :ok (200)' do
      send_request
      expect(response).to have_http_status(:ok)
    end

    it 'should set vacation request status to "inprogress"' do
      expect { send_request }
        .to change { VacationRequest.find_by(id: vacation.id).status }
        .to('inprogress')
    end
  end

  ################################################################# POST #create
  describe 'POST #create' do
    let(:send_request) { post :create, params }
    let(:params) { Hash[format: :json, vacation_request: json_data] }
    let(:json_data) { YAML.load(vacation.to_json) }
    let(:vacation) { build(:vacation_request) }

    context 'from authenticated user with manager role' do
      before { sign_in user }

      context 'who has roles only in one team' do
        context 'with correct data' do
          it 'should respond with status code :created (201)' do
            send_request
            expect(response).to have_http_status(:created)
          end

          it 'should add correct vacation request record to DB' do
            expect { send_request }.to change(VacationRequest, :count).by(+1)

            selectors = { start_date: vacation.start_date }
            new_vacation = VacationRequest.find_by(selectors)
            expect(new_vacation.status).not_to be_nil
            expect(new_vacation.status).to eq('accepted')
          end

          it 'should not add any approval request record to DB' do
            expect { send_request }.not_to change(ApprovalRequest, :count)
          end
        end

        context 'with incorrect data' do
          let(:vacation) { build(:vacation_request, :invalid) }

          it 'should respond with status code :unprocessable_entity (422)' do
            send_request
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'should contain error message as JSON data in response body' do
            send_request
            expect(response.body).to have_json_attribute(:errors)
          end

          it 'should not add any record to DB' do
            expect { send_request }.not_to change(VacationRequest, :count)
            expect { send_request }.not_to change(ApprovalRequest, :count)
          end
        end
      end
    end

    context 'from authenticated user with member role' do
      let(:user) { member }

      before { sign_in user }

      context 'who has roles only in one team' do
        context 'with correct data' do
          it 'should respond with status code :created (201)' do
            send_request
            expect(response).to have_http_status(:created)
          end

          it 'should add vacation request record to DB' do
            expect { send_request }.to change(VacationRequest, :count).by(+1)
          end

          it 'should add correct approval request record to DB' do
            expect { send_request }.to change(ApprovalRequest, :count).by(+1)

            selectors = { start_date: vacation.start_date }
            new_vacation = VacationRequest.find_by(selectors)
            expect(new_vacation.status).not_to be_nil
            expect(new_vacation.status).to eq('requested')
            expect(new_vacation.end_date).not_to be_nil

            selectors = { vacation_request_id: new_vacation.id }
            expect(ApprovalRequest.find_by(selectors)).not_to be_nil
          end
        end

        context 'with incorrect data' do
          let(:vacation) { build(:vacation_request, :invalid) }

          it 'should respond with status code :unprocessable_entity (422)' do
            send_request
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'should contain error message as JSON data in response body' do
            send_request
            expect(response.body).to have_json_attribute(:errors)
          end

          it 'should not add any record to DB' do
            expect { send_request }.not_to change(VacationRequest, :count)
          end
        end
      end
    end

    context 'from authenticated user with guest role' do
      let(:user) { guest }

      before { sign_in user }

      context 'who has roles only in one team,' do
        context 'with correct data' do
          it 'should respond with status code :forbidden (403)' do
            send_request
            expect(response).to have_http_status(:forbidden)
          end

          it 'should not add any vacation request record to DB' do
            expect { send_request }.not_to change(VacationRequest, :count)
          end

          it 'should not add any approval request record to DB' do
            expect { send_request }.not_to change(ApprovalRequest, :count)
          end
        end

        context 'with incorrect data' do
          let(:vacation) { build(:vacation_request, :invalid) }

          it 'should respond with status code :forbidden (403)' do
            send_request
            expect(response).to have_http_status(:forbidden)
          end

          it 'should not add any vacation request record to DB' do
            expect { send_request }.not_to change(VacationRequest, :count)
          end

          it 'should not add any approval request record to DB' do
            expect { send_request }.not_to change(ApprovalRequest, :count)
          end
        end
      end
    end

    context 'from unauthenticated user' do
      context 'with correct data' do
        it_should_behave_like 'unauthenticated request'

        it 'should not add any record to DB' do
          expect { send_request }.not_to change(VacationRequest, :count)
        end
      end
    end
  end

  ############################################################### GET #approvers
  describe 'GET #approvers' do
    let(:team) do
      create :team, :with_users, number_of_managers: 2, number_of_members: 1
    end
    let(:send_request) { get :approvers, params }
    let(:params) { Hash[format: :json, id: vacation.id] }

    context 'from authenticated user' do
      before { sign_in user }

      context 'with ID of not existing vacation request' do
        let(:params) { Hash[format: :json, id: (vacation.id - 1)] }

        it 'should respond with status code :not_found (404)' do
          send_request
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'with manager role' do
        context 'who owns the vacation request' do
          let(:vacation) do
            create(:vacation_request, :with_approval_requests, user: user)
          end

          it_should_behave_like 'unauthorized request'
        end

        context 'who does not own the vacation request' do
          let(:vacation) do
            create(:vacation_request, :with_approval_requests, user: member)
          end

          it_should_behave_like 'unauthorized request'
        end
      end

      context 'with member role' do
        let(:user) { member }
        context 'who owns the vacation request' do
          let(:vacation) do
            create(:vacation_request, :with_approval_requests, user: user)
          end

          it_should_behave_like 'pretty approvers request'
        end

        context 'who does not own the vacation request' do
          let(:vacation) do
            create(:vacation_request, :with_approval_requests, user: manager)
          end

          it_should_behave_like 'unauthorized request'
        end
      end

      context 'with guest role' do
        let(:user) { guest }
        context 'who owns the vacation request' do
          let(:vacation) do
            create(:vacation_request, :with_approval_requests, user: user)
          end

          it_should_behave_like 'unauthorized request'
        end
      end
    end

    context 'from unauthenticated user' do
      it_should_behave_like 'unauthenticated request'
    end
  end

  ################################################################## GET #cancel
  describe 'GET #cancel' do
    let(:team) do
      create :team, :with_users, number_of_managers: 2, number_of_members: 1
    end
    let(:send_request) { get :cancel, params }
    let(:params) { Hash[format: :json, id: vacation.id] }

    context 'from authenticated user' do
      before { sign_in user }

      context 'with ID of not existing vacation request' do
        let(:params) { Hash[format: :json, id: (vacation.id - 1)] }

        it 'should respond with status code :not_found (404)' do
          send_request
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'with manager role' do
        context 'who owns the vacation request' do
          let(:vacation) do
            create(:vacation_request, :with_approval_requests, user: user)
          end

          context 'when vacation request status is set to "requested"' do
            it 'should delete all associated approval requests' do
              expect { send_request }
                .to change { vacation.approval_requests.count }
                .from(1).to(0)
            end

            it_should_behave_like 'pretty cancel request'
          end

          context 'when vacation request status is set to "accepted"' do
            let(:vacation) do
              create(:vacation_request, user: user, status: 'accepted')
            end

            it_should_behave_like 'pretty cancel request'
          end
        end

        context 'who does not own the vacation request' do
          let(:vacation) do
            create(:vacation_request, :with_approval_requests, user: member)
          end

          it 'should not change vacation request status' do
            id = vacation.id

            expect { send_request }
              .not_to change { VacationRequest.find_by(id: id).status }
          end

          it 'should not delete associated approval requests' do
            expect { send_request }
              .not_to change { vacation.approval_requests.count }
          end

          it_should_behave_like 'unauthorized request'
        end
      end

      context 'with member role' do
        let(:user) { member }
        context 'who owns the vacation request' do
          let(:vacation) do
            create(:vacation_request, :with_approval_requests, user: user)
          end

          context 'when vacation request status is set to "requested"' do
            it 'should delete all associated approval requests' do
              expect { send_request }
                .to change { vacation.approval_requests.count }
                .from(2).to(0)
            end

            it_should_behave_like 'pretty cancel request'
          end

          context 'when vacation request status is set to "accepted"' do
            let(:vacation) do
              create(:vacation_request, user: user, status: 'accepted')
            end

            it_should_behave_like 'pretty cancel request'
          end
        end

        context 'who does not own the vacation request' do
          let(:vacation) do
            create(:vacation_request, :with_approval_requests, user: manager)
          end

          it 'should not change vacation request status' do
            id = vacation.id

            expect { send_request }
              .not_to change { VacationRequest.find_by(id: id).status }
          end

          it 'should not delete associated approval requests' do
            expect { send_request }
              .not_to change { vacation.approval_requests.count }
          end

          it_should_behave_like 'unauthorized request'
        end
      end

      context 'with guest role' do
        let(:user) { guest }
        context 'who owns the vacation request' do
          let(:vacation) do
            create(:vacation_request, :with_approval_requests, user: user)
          end

          it 'should not change vacation request status' do
            id = vacation.id

            expect { send_request }
              .not_to change { VacationRequest.find_by(id: id).status }
          end

          it_should_behave_like 'unauthorized request'
        end
      end

      context 'when vacation request status is set to "declined"' do
        let(:vacation) do
          create(:vacation_request, user: user, status: 'declined')
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "cancelled"' do
        let(:vacation) do
          create(:vacation_request, user: user, status: 'cancelled')
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "inprogress"' do
        let(:vacation) do
          create(:vacation_request, user: user, status: 'inprogress')
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "used"' do
        let(:vacation) do
          create(:vacation_request, user: user, status: 'used')
        end

        it_should_behave_like 'request with conflict'
      end
    end

    context 'from unauthenticated user' do
      it_should_behave_like 'unauthenticated request'

      it 'should not change vacation request status' do
        id = vacation.id
        expect { send_request }
          .not_to change { VacationRequest.find_by(id: id).status }
      end
    end
  end

  ################################################################## GET #finish
  describe 'GET #finish' do
    let(:team) do
      create :team, :with_users, number_of_managers: 2, number_of_members: 1
    end

    let(:create_available_vacations) do
      create(:available_vacation,
             user: user,
             available_days: user.accumulated_days(:planned),
             kind: :planned)
    end

    let(:send_request) { get :finish, params }
    let(:params) { Hash[format: :json, id: vacation.id] }

    context 'from authenticated user' do
      before { sign_in user }

      context 'with ID of not existing vacation request' do
        let(:params) { Hash[format: :json, id: (vacation.id - 1)] }

        it 'should respond with status code :not_found (404)' do
          send_request
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'with manager role' do
        context 'who owns the vacation request' do
          context 'when vacation request status is set to "inprogress"' do
            before do
              create_available_vacations
              vacation.status = 'inprogress'
              vacation.save!
            end

            it_should_behave_like 'pretty finish request'
          end
        end

        context 'who does not own the vacation request' do
          let(:vacation) do
            create(:vacation_request, :with_approval_requests, user: member)
          end

          it 'should not change vacation request status' do
            id = vacation.id

            expect { send_request }
              .not_to change { VacationRequest.find_by(id: id).status }
          end

          it_should_behave_like 'unauthorized request'
        end
      end

      context 'with member role' do
        let(:user) { member }
        context 'who owns the vacation request' do
          context 'when vacation request status is set to "inprogress"' do
            before do
              create_available_vacations
              vacation.status = 'inprogress'
              vacation.save!
            end

            it_should_behave_like 'pretty finish request'
          end
        end

        context 'who does not own the vacation request' do
          let(:vacation) do
            create(:vacation_request, :with_approval_requests, user: manager)
          end

          it 'should not change vacation request status' do
            id = vacation.id

            expect { send_request }
              .not_to change { VacationRequest.find_by(id: id).status }
          end

          it_should_behave_like 'unauthorized request'
        end
      end

      context 'with guest role' do
        let(:user) { guest }
        context 'who owns the vacation request' do
          let(:vacation) do
            create(:vacation_request, :with_approval_requests, user: user)
          end

          it 'should not change vacation request status' do
            id = vacation.id

            expect { send_request }
              .not_to change { VacationRequest.find_by(id: id).status }
          end

          it_should_behave_like 'unauthorized request'
        end
      end

      context 'when vacation request status is set to "requested"' do
        let(:vacation) do
          create(:vacation_request, user: user, status: 'requested')
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "accepted"' do
        let(:vacation) do
          create(:vacation_request, user: user, status: 'accepted')
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "declined"' do
        let(:vacation) do
          create(:vacation_request, user: user, status: 'declined')
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "cancelled"' do
        let(:vacation) do
          create(:vacation_request, user: user, status: 'cancelled')
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "used"' do
        let(:vacation) do
          create(:vacation_request, user: user, status: 'used')
        end

        it_should_behave_like 'request with conflict'
      end
    end

    context 'from unauthenticated user' do
      it_should_behave_like 'unauthenticated request'

      it 'should not change vacation request status' do
        id = vacation.id
        expect { send_request }
          .not_to change { VacationRequest.find_by(id: id).status }
      end
    end
  end

  ################################################################### GET #start
  describe 'GET #start' do
    let(:team) do
      create :team, :with_users, number_of_managers: 2, number_of_members: 1
    end
    let(:send_request) { get :start, params }
    let(:params) { Hash[format: :json, id: vacation.id] }

    context 'from authenticated user' do
      before { sign_in user }

      context 'with ID of not existing vacation request' do
        let(:params) { Hash[format: :json, id: (vacation.id - 1)] }

        it 'should respond with status code :not_found (404)' do
          send_request
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'with manager role' do
        context 'who owns the vacation request' do
          let(:vacation) do
            create(:vacation_request, :with_approval_requests, user: user)
          end

          context 'when vacation request status is set to "accepted"' do
            let(:vacation) do
              create(:vacation_request, user: user, status: 'accepted')
            end

            it_should_behave_like 'pretty start request'
          end
        end

        context 'who does not own the vacation request' do
          let(:vacation) do
            create(:vacation_request, :with_approval_requests, user: member)
          end

          it 'should not change vacation request status' do
            id = vacation.id

            expect { send_request }
              .not_to change { VacationRequest.find_by(id: id).status }
          end

          it_should_behave_like 'unauthorized request'
        end
      end

      context 'with member role' do
        let(:user) { member }
        context 'who owns the vacation request' do
          let(:vacation) do
            create(:vacation_request, :with_approval_requests, user: user)
          end

          context 'when vacation request status is set to "accepted"' do
            let(:vacation) do
              create(:vacation_request, user: user, status: 'accepted')
            end

            it_should_behave_like 'pretty start request'
          end
        end

        context 'who does not own the vacation request' do
          let(:vacation) do
            create(:vacation_request, :with_approval_requests, user: manager)
          end

          it 'should not change vacation request status' do
            id = vacation.id

            expect { send_request }
              .not_to change { VacationRequest.find_by(id: id).status }
          end

          it_should_behave_like 'unauthorized request'
        end
      end

      context 'with guest role' do
        let(:user) { guest }
        context 'who owns the vacation request' do
          let(:vacation) do
            create(:vacation_request, :with_approval_requests, user: user)
          end

          it 'should not change vacation request status' do
            id = vacation.id

            expect { send_request }
              .not_to change { VacationRequest.find_by(id: id).status }
          end

          it_should_behave_like 'unauthorized request'
        end
      end

      context 'when vacation request status is set to "requested"' do
        let(:vacation) do
          create(:vacation_request, user: user, status: 'requested')
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "declined"' do
        let(:vacation) do
          create(:vacation_request, user: user, status: 'declined')
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "cancelled"' do
        let(:vacation) do
          create(:vacation_request, user: user, status: 'cancelled')
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "inprogress"' do
        let(:vacation) do
          create(:vacation_request, user: user, status: 'inprogress')
        end

        it_should_behave_like 'request with conflict'
      end

      context 'when vacation request status is set to "used"' do
        let(:vacation) do
          create(:vacation_request, user: user, status: 'used')
        end

        it_should_behave_like 'request with conflict'
      end
    end

    context 'from unauthenticated user' do
      it_should_behave_like 'unauthenticated request'

      it 'should not change vacation request status' do
        id = vacation.id
        expect { send_request }
          .not_to change { VacationRequest.find_by(id: id).status }
      end
    end
  end
end
