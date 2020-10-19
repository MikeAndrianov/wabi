# frozen_string_literal: true

describe Middleware::StaticDispatch do
  subject(:static_dispatch) { described_class.new(app) }

  let(:app) { ->(env) { env } }
  let(:env) { Rack::MockRequest.env_for(url, env_options) }
  let(:url) { 'assets/app.css' }
  let(:env_options) { {} }

  describe '#call' do
    subject { static_dispatch.call(env) }

    let(:file_instance) do
      instance_double(
        Middleware::Files,
        find: is_found,
        mime_type: 'text/css',
        body: 'h1 { color: red }'
      )
    end
    let(:is_found) { true }

    before do
      allow(Middleware::Files)
        .to receive(:new)
        .with('public/app.css')
        .and_return(file_instance)
    end

    context 'when file is available' do
      it { is_expected.to eq([200, { 'Content-Type' => 'text/css' }, ['h1 { color: red }']]) }
    end

    context 'when file is not available' do
      let(:is_found) { false }

      it { is_expected.to eq([404, {}, ['Not Found']]) }
    end

    context 'with inappropriate request type' do
      let(:env_options) do
        { 'REQUEST_METHOD' => 'POST' }
      end

      it { is_expected.to eq([400, {}, ['Bad Request']]) }
    end
  end
end
