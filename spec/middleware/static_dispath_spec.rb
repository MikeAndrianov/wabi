# frozen_string_literal: true

describe Middleware::StaticDispatch do
  subject(:static_dispatch) { described_class.new(app) }

  let(:app) { ->(env) { env } }
  let(:env) { Rack::MockRequest.env_for(url, env_options) }
  let(:url) { 'assets/app.css' }
  let(:env_options) { {} }

  describe '#call' do
    subject(:response) { static_dispatch.call(env) }

    let(:file_instance) do
      instance_double(
        Middleware::Utils::Files,
        find: is_found,
        mime_type: 'text/css',
        body: 'h1 { color: red }'
      )
    end
    let(:is_found) { true }

    before do
      allow(Middleware::Utils::Files)
        .to receive(:new)
        .with('public/app.css')
        .and_return(file_instance)
    end

    context 'when file is available' do
      it { expect(response[0]).to eq(200) }
      it { expect(response[2]).to eq(['h1 { color: red }']) }

      it 'returns proper set of headers' do
        headers = response[1]

        expect(headers['Content-Type']).to eq('text/css')
        expect(headers['Cache-Control']).to eq('public, max-age=31536000')
        expect(headers).to include('Expires')
      end
    end

    context 'when file is not available' do
      let(:is_found) { false }

      it { expect(response[0]).to eq(404) }
      it { expect(response[2]).to eq(['Not Found']) }

      it 'returns proper set of headers' do
        headers = response[1]

        expect(headers['Cache-Control']).to eq('public, max-age=31536000')
        expect(headers).to include('Expires')
      end
    end

    context 'with inappropriate request type' do
      let(:env_options) do
        { 'REQUEST_METHOD' => 'POST' }
      end

      it { is_expected.to eq([400, {}, ['Bad Request']]) }
    end
  end
end
