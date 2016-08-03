RSpec.shared_examples 'unauthorized request' do
  before { send_request }

  it { expect(response).to have_http_status(:forbidden) }
end
