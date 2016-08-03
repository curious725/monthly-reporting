require 'rails_helper'

RSpec.describe TeamRolesController do
  let(:team) { create(:team) }
  let(:user) { create(:user) }
  let(:guest) { build(:team_role, role: 'guest', user: user, team: team) }
  let(:member) { build(:team_role, role: 'member', user: user, team: team) }
  let(:manager) { build(:team_role, role: 'manager', user: user, team: team) }
  let(:admin) { build(:team_role, role: 'admin', user: user, team: team) }

  shared_examples 'pretty request' do
    it 'should not throw an exception' do
      expect { send_request }.not_to raise_error
    end

    it 'should respond with status code :ok (200)' do
      send_request
      expect(response).to have_http_status(:ok)
    end
  end

  ################################################################### GET #index
  describe 'GET #index, format: :json' do
    let(:create_team) { create(:team, :compact) }
    let(:team_roles) { create_team.team_roles }

    let(:send_request) { get :index, format: :json }

    before { create_team }

    context 'from authenticated user' do
      before do
        sign_in user
        send_request
      end

      it { expect(response).to have_http_status(:ok) }

      it 'should respond with records with correct IDs' do
        expect(response.body).to match_records_by_ids_with(team_roles)
      end

      it 'should respond with particular set of roles' do
        expect(response.body).to have_json_attribute(:role)
          .with_value('guest')
        expect(response.body).to have_json_attribute(:role)
          .with_value('member')
        expect(response.body).to have_json_attribute(:role)
          .with_value('manager')
        expect(response.body).to have_json_attribute(:role)
          .with_value('admin')
      end

      it 'should respond with properly structured records' do
        expected = %w(id role team_id user_id)
        expect(response.body).to have_json_attributes(expected)
      end
    end

    context 'from unauthenticated user' do
      before { send_request }

      it_should_behave_like 'unauthenticated request'
    end
  end

  ################################################################# POST #create
  describe 'POST #create' do
    let(:team_role)     { manager }
    let(:params)        { Hash[format: :json, team_role: json_data] }
    let(:json_data)     { YAML.load(team_role.to_json) }
    let(:send_request)  { post :create, params }

    context 'from authenticated user with role=admin' do
      before { admin.save }
      before { sign_in user }

      context 'with correct data' do
        it 'should add a correct record to DB' do
          expect { send_request }.to change(TeamRole, :count).by(+1)
          keys = %w(role team_id user_id)
          record = TeamRole.find_by(team_role.attributes.slice(keys))
          expect(record).not_to be_nil
        end

        it 'should respond with properly structured records' do
          send_request
          expected = %w(id role team_id user_id created_at updated_at)
          expect(response.body).to have_json_attributes(expected)
        end

        it 'should respond with created record as JSON' do
          send_request
          expect(response.body).to have_json_attribute(:role)
            .with_value(team_role.role)
          expect(response.body).to have_json_attribute(:team_id)
            .with_value(team.id)
          expect(response.body).to have_json_attribute(:user_id)
            .with_value(user.id)
        end

        it_should_behave_like 'pretty request'
      end

      context 'with incorrect data' do
        let(:team_role) { build(:team_role, role: '') }

        it 'should respond with status code :unprocessable_entity (422)' do
          send_request
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should contain error message as JSON data in response body' do
          send_request
          expect(response.body).to have_json_attribute(:errors)
        end

        it 'should not add any record to DB' do
          expect { send_request }.not_to change(TeamRole, :count)
        end
      end
    end

    context 'from authenticated user with role=manager' do
      before { manager.save }
      before { sign_in user }

      it_should_behave_like 'unauthorized request'
    end

    context 'from authenticated user with role=member' do
      before { member.save }
      before { sign_in user }

      it_should_behave_like 'unauthorized request'
    end

    context 'from authenticated user with role=guest' do
      before { guest.save }
      before { sign_in user }

      it_should_behave_like 'unauthorized request'
    end

    context 'from unauthenticated user' do
      it_should_behave_like 'unauthenticated request'

      it 'should not add any record to DB' do
        expect { send_request }.not_to change(TeamRole, :count)
      end
    end
  end

  ############################################################## DELETE #destroy
  describe 'DELETE #destroy' do
    let(:team_role)     { manager }
    let(:params)        { Hash[format: :json, id: team_role.id] }
    let(:send_request)  { delete :destroy, params }

    before { team_role.save }

    context 'from authenticated user with role=admin' do
      before { admin.save }
      before { sign_in user }

      it 'should respond with status code :no_content (204)' do
        send_request
        expect(response).to have_http_status(:no_content)
      end

      it 'should delete specified record' do
        expect { send_request }.to change(TeamRole, :count).by(-1)
        expect(TeamRole.find_by(id: team_role.id)).to be_nil
      end

      describe 'with attempt to delete a record that does not exist' do
        before { delete :destroy, id: (team_role.id - 1) }

        it { expect(response).to have_http_status(:not_found) }
      end
    end

    context 'from authenticated user with role=manager' do
      before { manager.save }
      before { sign_in user }

      it_should_behave_like 'unauthorized request'
    end

    context 'from authenticated user with role=member' do
      before { member.save }
      before { sign_in user }

      it_should_behave_like 'unauthorized request'
    end

    context 'from authenticated user with role=guest' do
      before { guest.save }
      before { sign_in user }

      it_should_behave_like 'unauthorized request'
    end

    context 'from unauthenticated user' do
      let(:initial_number_of_records) { TeamRole.count }

      before do
        initial_number_of_records
        send_request
      end

      it_should_behave_like 'unauthenticated request'

      it 'should not delete specified record' do
        expect(TeamRole.find_by(id: team_role.id)).not_to be_nil
      end

      it 'should not delete any record' do
        expect(TeamRole.count).to be(initial_number_of_records)
      end
    end
  end
end
