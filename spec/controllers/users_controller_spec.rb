require 'rails_helper'

RSpec.describe UsersController do
  let(:team) { create(:team, :compact) }
  let(:admin)   { team.team_roles.admins.first.user }
  let(:manager) { team.team_roles.managers.first.user }
  let(:member)  { team.team_roles.members.first.user }
  let(:guest)   { team.team_roles.guests.first.user }
  let(:simple_user) { create(:user) }

  shared_examples 'pretty request' do
    it 'should not throw an exception' do
      expect { send_request }.not_to raise_error
    end

    it 'should respond with status code :ok (200)' do
      send_request
      expect(response).to have_http_status(:ok)
    end
  end

  shared_examples 'empty approval_requests request' do
    it 'should not throw an exception' do
      expect { send_request }.not_to raise_error
    end

    it 'should respond with status code :ok (200)' do
      send_request
      expect(response).to have_http_status(:ok)
    end

    it 'should respond with proper JSON data structure' do
      send_request
      expected = []
      expect(response.body).to have_json_attributes(expected)
    end
  end

  shared_examples 'pretty approval_requests request' do
    it 'should not throw an exception' do
      expect { send_request }.not_to raise_error
    end

    it 'should respond with status code :ok (200)' do
      send_request
      expect(response).to have_http_status(:ok)
    end

    it 'should respond with proper JSON data structure' do
      send_request
      expected = %w(id kind start_date end_date first_name last_name user_id)
      expect(response.body).to have_json_attributes(expected)
    end
  end

  ################################################################### GET #index
  describe 'GET #index, format: :json' do
    let(:send_request) { get :index, format: :json }
    let(:create_users) { users }
    let(:users) { create_list(:user, 5) }

    context 'from authenticated user' do
      before do
        create_users
        create(:team_role, team: team, user: users.first)
        sign_in member
        send_request
      end

      it { expect(response).to have_http_status(:ok) }
      it 'should contain correct records as JSON data in response body' do
        expected = team.users
        expect(response.body).to match_records_by_ids_with(expected)
      end
    end

    context 'from unauthenticated user' do
      before { send_request }

      it_should_behave_like 'unauthenticated request'
    end
  end

  ################################################################# POST #create
  describe 'POST #create, format: :json' do
    let(:new_user) { build(:user) }
    let(:params)        { Hash[format: :json, user: json_data] }
    let(:json_data)     { YAML.load(new_user.to_json) }
    let(:send_request)  { post :create, params }

    context 'from authenticated user' do
      before { sign_in user }

      context 'with role=admin' do
        let(:user) { admin }

        context 'with correct data' do
          it 'should add a correct record to DB' do
            expect { send_request }.to change(User, :count).by(+1)
            record = User.find_by(email: new_user.email)
            expect(record).not_to be_nil
          end

          it 'should respond with properly structured records' do
            send_request
            expected = %w(id first_name last_name email birth_date)
            expected << 'invitation_accepted_at'
            expected << 'employment_date'

            expect(response.body).to have_json_attributes(expected)
          end

          it 'should respond with created record as JSON' do
            send_request
            expect(response.body).to have_json_attribute(:first_name)
              .with_value(new_user.first_name)
            expect(response.body).to have_json_attribute(:last_name)
              .with_value(new_user.last_name)
            expect(response.body).to have_json_attribute(:email)
              .with_value(new_user.email)
          end

          it_should_behave_like 'pretty request'
        end

        context 'with incorrect data' do
          before { new_user.email = '' }

          it 'should respond with status code :unprocessable_entity (422)' do
            send_request
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'should contain error message as JSON data in response body' do
            send_request
            expect(response.body).to have_json_attribute(:errors)
          end

          it 'should not add any record to DB' do
            expect { send_request }.not_to change(User, :count)
          end
        end
      end

      context 'with role=manager' do
        let(:user) { manager }
        it_should_behave_like 'unauthorized request'
      end

      context 'with role=member' do
        let(:user) { member }
        it_should_behave_like 'unauthorized request'
      end

      context 'with role=guest' do
        let(:user) { guest }
        it_should_behave_like 'unauthorized request'
      end

      context 'with no roles' do
        let(:user) { simple_user }
        it_should_behave_like 'unauthorized request'
      end
    end

    context 'from unauthenticated user' do
      it_should_behave_like 'unauthenticated request'

      it 'should not add any record to DB' do
        expect { send_request }.not_to change(User, :count)
      end
    end
  end

  ################################################################ PATCH #update
  describe 'PATCH #update, format: :json' do
    let(:create_user)   { create(:user) }
    let(:existing_user) { create_user }
    let(:updated_user)  { build(:user) }
    let(:params) { Hash[format: :json, id: existing_user.id, user: json_data] }
    let(:json_data)     { YAML.load(updated_user.to_json) }
    let(:send_request)  { patch :update, params }

    before { create_user }

    context 'from authenticated user' do
      before { sign_in user }

      context 'with role=admin' do
        let(:user) { admin }

        context 'with correct data' do
          it 'should update specified record in DB' do
            expect { send_request }.not_to change(User, :count)
            record = User.find_by(id: existing_user.id)
            expect(record).not_to be_nil
            expect(record.email).to eq(updated_user.email)
          end

          it 'should respond with properly structured records' do
            send_request
            expected = %w(id first_name last_name email birth_date)
            expected << 'invitation_accepted_at'
            expected << 'employment_date'

            expect(response.body).to have_json_attributes(expected)
          end

          it 'should respond with updated record as JSON' do
            send_request
            expect(response.body).to have_json_attribute(:first_name)
              .with_value(updated_user.first_name)
            expect(response.body).to have_json_attribute(:last_name)
              .with_value(updated_user.last_name)
            expect(response.body).to have_json_attribute(:email)
              .with_value(updated_user.email)
          end

          it_should_behave_like 'pretty request'
        end

        context 'with incorrect data' do
          before { updated_user.email = '' }

          it 'should respond with status code :unprocessable_entity (422)' do
            send_request
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'should contain error message as JSON data in response body' do
            send_request
            expect(response.body).to have_json_attribute(:errors)
          end

          it 'should not add any record to DB' do
            expect { send_request }.not_to change(User, :count)
          end

          it 'should not update specified record in DB' do
            expect { send_request }.not_to change(User, :count)
            record = User.find_by(id: existing_user.id)
            expect(record).not_to be_nil
            expect(record.first_name).not_to eq(updated_user.first_name)
            expect(record.last_name).not_to eq(updated_user.last_name)
          end
        end
      end

      context 'with role=manager' do
        let(:user) { manager }
        it_should_behave_like 'unauthorized request'
      end

      context 'with role=member' do
        let(:user) { member }
        it_should_behave_like 'unauthorized request'
      end

      context 'with role=guest' do
        let(:user) { guest }
        it_should_behave_like 'unauthorized request'
      end

      context 'with no roles' do
        let(:user) { simple_user }
        it_should_behave_like 'unauthorized request'
      end
    end

    context 'from unauthenticated user' do
      it_should_behave_like 'unauthenticated request'

      it 'should not add any record to DB' do
        expect { send_request }.not_to change(User, :count)
      end
    end
  end

  ############################################################## DELETE #destroy
  describe 'DELETE #destroy' do
    let(:create_user)   { create(:user) }
    let(:existing_user) { create_user }
    let(:params) { Hash[format: :json, id: existing_user.id] }
    let(:json_data)     { YAML.load(updated_user.to_json) }
    let(:send_request)  { delete :destroy, params }

    before { create_user }

    context 'from authenticated user' do
      before { sign_in user }

      context 'with role=admin' do
        let(:user) { admin }

        it 'should respond with status code :no_content (204)' do
          send_request
          expect(response).to have_http_status(:no_content)
        end

        it 'should delete specified record' do
          expect { send_request }.to change(User, :count).by(-1)
          expect(User.find_by(id: existing_user.id)).to be_nil
        end

        describe 'with attempt to delete a record that does not exist' do
          before { delete :destroy, id: 0 }

          it { expect(response).to have_http_status(:not_found) }
        end
      end

      context 'with role=manager' do
        let(:user) { manager }
        it_should_behave_like 'unauthorized request'
      end

      context 'with role=member' do
        let(:user) { member }
        it_should_behave_like 'unauthorized request'
      end

      context 'with role=guest' do
        let(:user) { guest }
        it_should_behave_like 'unauthorized request'
      end

      context 'with no roles' do
        let(:user) { simple_user }
        it_should_behave_like 'unauthorized request'
      end
    end

    context 'from unauthenticated user' do
      it_should_behave_like 'unauthenticated request'

      it 'should not add any record to DB' do
        expect { send_request }.not_to change(User, :count)
      end
    end
  end

  ####################################################### GET #approval_requests
  describe 'GET #approval_requests, format: :json' do
    let(:send_request) { get :approval_requests, params }
    let(:params) { Hash[format: :json, id: user.id] }

    context 'from unauthenticated user' do
      let(:params) { Hash[format: :json, id: 0] }
      before { send_request }

      it_should_behave_like 'unauthenticated request'
    end

    context 'from authenticated user' do
      before { sign_in user }

      context 'with manager role' do
        let(:user) { manager }

        context 'without any assigned approval request' do
          it_should_behave_like 'empty approval_requests request'
        end

        context 'with an assigned approval request' do
          let(:vacation) do
            create(:vacation_request, user: member)
          end

          before do
            ApprovalRequest.create(manager_id: user.id,
                                   vacation_request_id: vacation.id)
          end

          it_should_behave_like 'pretty approval_requests request'
        end
      end
    end
  end
end
