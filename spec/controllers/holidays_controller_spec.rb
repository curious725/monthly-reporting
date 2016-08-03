require 'rails_helper'

RSpec.describe HolidaysController do
  let(:team) { create(:team, :compact) }
  let(:admin) { team.team_roles.admins.first.user }
  let(:manager) { team.team_roles.managers.first.user }
  let(:user) { create(:user) }
  let(:holiday) { create(:holiday, description: 'Ruby Day') }

  ################################################################### GET #index
  describe 'GET #index, format: :json' do
    let(:holidays) { create_list(:holiday, 2) }
    let(:send_request) { get :index, format: :json }

    context 'from authenticated user' do
      before do
        holidays
        sign_in user
        send_request
      end

      it { expect(response).to have_http_status(:ok) }
      it 'should contain correct records as JSON data in response body' do
        expect(response.body).to match_records_by_ids_with(holidays)
      end
    end

    context 'from unauthenticated user' do
      before { send_request }

      it_should_behave_like 'unauthenticated request'
    end
  end

  ################################################################# POST #create
  describe 'POST #create' do
    let(:params) { Hash[format: :json, holiday: json_data] }
    let(:another_holiday) { build(:holiday) }
    let(:json_data)     { YAML.load(another_holiday.to_json) }
    let(:send_request)  { post :create, params }

    context 'from authenticated user with role=admin' do
      before { sign_in admin }

      context 'with correct data' do
        it 'should respond with status code :ok (200)' do
          send_request
          expect(response).to have_http_status(:ok)
        end

        it 'should add a correct record to DB' do
          expect { send_request }.to change(Holiday, :count).by(+1)
          expect(Holiday.find_by(description: another_holiday.description))
            .not_to be_nil
        end

        it 'should respond with created record as JSON' do
          send_request
          expect(response.body).to have_json_attribute(:description)
            .with_value(another_holiday.description)
        end
      end

      context 'with incorrect data' do
        let(:another_holiday) { build(:holiday, description: 'Day') }

        it 'should respond with status code :unprocessable_entity (422)' do
          send_request
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should contain error message as JSON data in response body' do
          send_request
          expect(response.body).to have_json_attribute(:errors)
        end

        it 'should not add any record to DB' do
          expect { send_request }.not_to change(Holiday, :count)
        end
      end
    end

    context 'from authenticated user with role=manager' do
      before { sign_in manager }

      it_should_behave_like 'unauthorized request'

      it 'should not add any record to DB' do
        expect { send_request }.not_to change(Holiday, :count)
      end
    end

    context 'from unauthenticated user' do
      context 'with correct data' do
        it_should_behave_like 'unauthenticated request'

        it 'should not add any record to DB' do
          expect { send_request }.not_to change(Holiday, :count)
        end
      end
    end
  end

  ################################################################ PATCH #update
  describe 'PATCH #update' do
    let(:params) { Hash[format: :json, id: holiday.id, holiday: json_data] }
    let(:another_holiday) { build(:holiday) }
    let(:json_data)     { YAML.load(another_holiday.to_json) }
    let(:send_request)  { patch :update, params }

    context 'from authenticated user with role=admin' do
      before { sign_in admin }

      context 'with correct data' do
        before { send_request }

        it 'should respond with status code :no_content (204)' do
          expect(response).to have_http_status(:no_content)
        end

        it 'should respond with no content' do
          expect(response.body).to be_blank
        end

        it 'should update specified record in DB' do
          expect(Holiday.find_by(id: holiday.id).description)
            .to eq(another_holiday.description)
        end
      end

      context 'with a reference to not existing record' do
        let(:params) { Hash[format: :json, id: 0, team: json_data] }

        it 'should respond with status code :not_found (404)' do
          send_request
          expect(response).to have_http_status(:not_found)
        end

        it 'should not add a record to DB' do
          expect { send_request }.to change(Holiday, :count).by(0)
        end
      end

      context 'with incorrect data' do
        let(:another_holiday) { build(:holiday, description: 'Day') }

        before { send_request }

        it { expect(response).to have_http_status(:unprocessable_entity) }
        it 'should contain error message as JSON data in response body' do
          expect(response.body).to have_json_attribute(:errors)
        end

        it 'should not update specified record in DB' do
          expect(Holiday.find_by(id: holiday.id).description)
            .to eq(holiday.description)
        end
      end
    end

    context 'from authenticated user with role=manager' do
      before { sign_in manager }

      it_should_behave_like 'unauthorized request'
    end

    context 'from unauthenticated user' do
      context 'with correct data' do
        before { send_request }

        it_should_behave_like 'unauthenticated request'

        it 'should not update specified record in DB' do
          expect(Holiday.find_by(id: holiday.id).description)
            .to eq(holiday.description)
        end
      end
    end
  end

  ############################################################## DELETE #destroy
  describe 'DELETE #destroy' do
    let(:params) { Hash[format: :json, id: holiday.id] }
    let(:send_request) { delete :destroy, params }

    before { holiday }

    context 'from authenticated user with role=admin' do
      before { sign_in admin }

      it 'should respond with status code :no_content (204)' do
        send_request
        expect(response).to have_http_status(:no_content)
      end

      it 'should delete specified record' do
        expect { send_request }.to change(Holiday, :count).by(-1)
        expect(Holiday.find_by(id: holiday.id)).to be_nil
      end

      describe 'with attempt to delete a record that does not exist' do
        let(:params) { Hash[format: :json, id: 0] }

        before { send_request }

        it { expect(response).to have_http_status(:not_found) }
      end
    end

    context 'from authenticated user with role=manager' do
      before { sign_in manager }

      it_should_behave_like 'unauthorized request'

      it 'should not delete specified record' do
        expect { send_request }.not_to change(Holiday, :count)
      end
    end

    context 'from unauthenticated user' do
      let(:initial_number_of_records) { Holiday.count }

      before do
        initial_number_of_records
        send_request
      end

      it_should_behave_like 'unauthenticated request'

      it 'should not delete specified record' do
        expect(Holiday.find_by(id: holiday.id)).not_to be_nil
      end

      it 'should not delete any record' do
        expect(Holiday.count).to be(initial_number_of_records)
      end
    end
  end
end
