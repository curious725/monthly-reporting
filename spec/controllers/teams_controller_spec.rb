require 'rails_helper'

RSpec.describe TeamsController do
  let(:user)  { create(:user) }
  let(:teams) { create_list(:team, 2) }

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
    let(:send_request) { get :index, format: :json }

    before { teams }

    context 'from authenticated user' do
      before do
        create(:team_role, user: user, team: teams.first, role: 'member')
        sign_in user
        send_request
      end

      it { expect(response).to have_http_status(:ok) }
      it 'should contain correct records as JSON data in response body' do
        expect(response.body).to match_records_by_ids_with([teams.first])
      end
    end

    context 'from unauthenticated user' do
      before { send_request }

      it_should_behave_like 'unauthenticated request'
    end
  end

  ################################################################# POST #create
  describe 'POST #create' do
    let(:another_team)  { create(:team, :compact) }
    let(:team)          { build(:team, name: 'Superheros') }
    let(:params)        { Hash[format: :json, team: Hash[:name, team.name]] }
    let(:send_request)  { post :create, params }

    context 'from authenticated user with role=admin' do
      let(:user) { another_team.team_roles.admins.first.user }
      before { sign_in user }

      context 'with correct data' do
        it 'should add a correct record to DB' do
          expect { send_request }.to change(Team, :count).by(+1)
          expect(Team.find_by(name: team.name)).not_to be_nil
        end

        it 'should respond with created record as JSON' do
          send_request
          expect(response.body).to have_json_attribute(:name)
            .with_value(team.name)
        end

        it_should_behave_like 'pretty request'
      end

      context 'with incorrect data' do
        let(:team) { build(:team, name: 'Oz') }

        it 'should respond with status code :unprocessable_entity (422)' do
          send_request
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should contain error message as JSON data in response body' do
          send_request
          expect(response.body).to have_json_attribute(:errors)
        end

        it 'should not add any record to DB' do
          expect { send_request }.not_to change(Team, :count)
        end
      end
    end

    context 'from authenticated user with role=manager' do
      let(:user) { another_team.team_roles.managers.first.user }
      let(:team) { build(:team, name: 'Superheros') }

      before { sign_in user }

      it_should_behave_like 'unauthorized request'
    end

    context 'from unauthenticated user' do
      it_should_behave_like 'unauthenticated request'

      it 'should not add any record to DB' do
        expect { send_request }.not_to change(Team, :count)
      end
    end
  end

  ################################################################## PUT #update
  describe 'PUT #update' do
    let(:params) { Hash[format: :json, id: team.id, team: json_data] }
    let(:team)          { create(:team, :compact) }
    let(:another_team)  { build(:team, name: 'Superheros') }
    let(:json_data)     { YAML.load(another_team.to_json) }
    let(:send_request)  { put :update, params }

    context 'from authenticated user with role=admin' do
      let(:user) { team.team_roles.admins.first.user }
      before { sign_in user }

      context 'with correct data' do
        before { send_request }

        it 'should respond with status code :ok (200)' do
          expect(response).to have_http_status(:ok)
        end

        it 'should respond with proper data' do
          expect(response.body).to have_json_attribute(:name)
            .with_value(another_team.name)
          expect(response.body).to have_json_attribute(:id)
            .with_value(team.id)
        end

        it 'should update specified record in DB' do
          expect(Team.find_by(id: team.id).name).to eq(another_team.name)
        end
      end

      context 'with a reference to not existing record' do
        let(:params)        { Hash[format: :json, id: 1, team: json_data] }
        let(:another_team)  { build(:team, name: 'Oz') }

        it 'should respond with status code :not_found (404)' do
          send_request
          expect(response).to have_http_status(:not_found)
        end

        it 'should not add a record to DB' do
          expect { send_request }.to change(Team, :count).by(0)
        end
      end

      context 'with incorrect data' do
        let(:another_team) { build(:team, name: 'Oz') }

        before { send_request }

        it { expect(response).to have_http_status(:unprocessable_entity) }
        it 'should contain error message as JSON data in response body' do
          expect(response.body).to have_json_attribute(:errors)
        end

        it 'should not update specified record in DB' do
          expect(Team.find_by(id: team.id).name).not_to eq(another_team.name)
        end
      end
    end

    context 'from authenticated user with role=manager' do
      let(:user) { team.team_roles.managers.first.user }
      before { sign_in user }

      it_should_behave_like 'unauthorized request'

      it 'should not add a record to DB' do
        expect { send_request }.to change(Team, :count).by(0)
      end
    end

    context 'from unauthenticated user' do
      before { send_request }

      it_should_behave_like 'unauthenticated request'

      it 'should not update specified record in DB' do
        expect(Team.find_by(id: team.id).name).to eq(team.name)
      end
    end
  end

  ################################################################ PATCH #update
  describe 'PATCH #update' do
    let(:params) { Hash[format: :json, id: team.id, team: json_data] }
    let(:team)          { create(:team, :compact) }
    let(:another_team)  { build(:team, name: 'Superheros') }
    let(:json_data)     { YAML.load(another_team.to_json) }
    let(:send_request)  { patch :update, params }

    context 'from authenticated user with role=admin' do
      let(:user) { team.team_roles.admins.first.user }
      before { sign_in user }

      context 'with correct data' do
        before { send_request }

        it 'should respond with status code :ok (200)' do
          expect(response).to have_http_status(:ok)
        end

        it 'should respond with proper data' do
          expect(response.body).to have_json_attribute(:name)
            .with_value(another_team.name)
          expect(response.body).to have_json_attribute(:id)
            .with_value(team.id)
        end

        it 'should update specified record in DB' do
          expect(Team.find_by(id: team.id).name).to eq(another_team.name)
        end
      end

      context 'with a reference to not existing record' do
        let(:params)        { Hash[format: :json, id: 1, team: json_data] }
        let(:another_team)  { build(:team, name: 'Oz') }

        it 'should respond with status code :not_found (404)' do
          send_request
          expect(response).to have_http_status(:not_found)
        end

        it 'should not add a record to DB' do
          expect { send_request }.to change(Team, :count).by(0)
        end
      end

      context 'with incorrect data' do
        let(:another_team) { build(:team, name: 'Oz') }

        before { send_request }

        it { expect(response).to have_http_status(:unprocessable_entity) }
        it 'should contain error message as JSON data in response body' do
          expect(response.body).to have_json_attribute(:errors)
        end

        it 'should not update specified record in DB' do
          expect(Team.find_by(id: team.id).name).not_to eq(another_team.name)
        end
      end
    end

    context 'from authenticated user with role=manager' do
      let(:user) { team.team_roles.managers.first.user }
      before { sign_in user }

      it_should_behave_like 'unauthorized request'

      it 'should not add a record to DB' do
        expect { send_request }.to change(Team, :count).by(0)
      end
    end

    context 'from unauthenticated user' do
      before { send_request }

      it_should_behave_like 'unauthenticated request'

      it 'should not update specified record in DB' do
        expect(Team.find_by(id: team.id).name).to eq(team.name)
      end
    end
  end

  ############################################################## DELETE #destroy
  describe 'DELETE #destroy' do
    let(:team)          { create(:team, :compact) }
    let(:params)        { Hash[format: :json, id: teams.first.id] }
    let(:send_request)  { delete :destroy, params }

    before { teams }

    context 'from authenticated user with role=admin' do
      let(:user) { team.team_roles.admins.first.user }

      before { sign_in user }

      it 'should respond with status code :no_content (204)' do
        send_request
        expect(response).to have_http_status(:no_content)
      end

      it 'should delete specified record' do
        expect { send_request }.to change(Team, :count).by(-1)
        expect(Team.find_by(id: teams.first.id)).to be_nil
      end

      describe 'with attempt to delete a record that does not exist' do
        before { delete :destroy, id: (teams.first.id - 1) }

        it { expect(response).to have_http_status(:not_found) }
      end
    end

    context 'from authenticated user with role=manager' do
      let(:user) { team.team_roles.managers.first.user }

      before { sign_in user }

      it_should_behave_like 'unauthorized request'
    end

    context 'from unauthenticated user' do
      let(:initial_number_of_teams) { Team.count }

      before do
        initial_number_of_teams
        delete :destroy, params
      end

      it_should_behave_like 'unauthenticated request'

      it 'should not delete specified record' do
        expect(Team.find_by(id: teams.first.id)).not_to be_nil
      end

      it 'should not delete any record' do
        expect(Team.count).to be(initial_number_of_teams)
      end
    end
  end

  ################################################################# GET #members
  describe 'GET #members' do
    let(:params)        { Hash[format: :json, id: team.id] }
    let(:team)          { create(:team) }
    let(:members)       { create_list(:user, 2) }
    let(:send_request)  { get :members, params }

    before do
      create(:team_role, user: members.first,  team: team)
      create(:team_role, user: members.second, team: team)
    end

    context 'from authenticated user' do
      before do
        sign_in user
        send_request
      end

      it { expect(response).to have_http_status(:ok) }
      it 'should contain correct records as JSON data in response body' do
        expect(response.body).to match_records_by_ids_with(members)
      end

      describe 'with attempt to get members for team that does not exist' do
        let(:params) { Hash[format: :json, id: (team.id - 1)] }
        before { send_request }

        it { expect(response).to have_http_status(:not_found) }
      end
    end

    context 'from unauthenticated user' do
      it_should_behave_like 'unauthenticated request'
    end
  end

  ############################################################### GET #vacations
  describe 'GET #vacations' do
    let(:member) { create(:user, :with_vacations_of_all_statuses) }
    let(:params)        { Hash[format: :json, id: team.id] }
    let(:team)          { create(:team) }
    let(:send_request)  { get :vacations, params }

    before do
      create(:user, :with_vacations_of_all_statuses)
      create(:team_role, user: member, team: team)
    end

    context 'from authenticated user' do
      before do
        sign_in user
        send_request
      end

      it { expect(response).to have_http_status(:ok) }
      it 'should contain correct records as JSON data in response body' do
        vacations = member.vacation_requests.not_cancelled_declined
        expect(response.body).to match_records_by_ids_with(vacations)
      end

      describe 'with attempt to get vacations of team that does not exist' do
        let(:params) { Hash[format: :json, id: (team.id - 1)] }
        before { send_request }

        it { expect(response).to have_http_status(:not_found) }
      end
    end

    context 'from unauthenticated user' do
      it_should_behave_like 'unauthenticated request'
    end
  end
end
