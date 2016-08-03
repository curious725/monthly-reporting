RSpec.shared_examples 'unauthenticated request' do
  before { send_request }

  it { expect(response).to have_http_status(:found) }
  it { expect(send_request).to redirect_to(new_user_session_path) }
end
