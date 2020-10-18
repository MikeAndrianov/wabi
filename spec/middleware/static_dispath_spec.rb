# frozen_string_literal: true

describe Middleware::StaticDispatch do
  subject(:static_dispatch) { described_class.new(app) }

  let(:app) { ->(_) { [200, {}, []] } }
  let(:env) { Rack::MockRequest.env_for(url, env_options) }
  let(:url) { 'app.css' }
  let(:env_options) { {} }

  describe '#call' do
    subject { static_dispatch.call(env) }

    context 'when file is available' do
      before do
        path = 'public/app.css'

        allow(static_dispatch).to receive(:file_available?).with(path).and_return(true)
        allow(static_dispatch).to receive(:mime_type).with(path).and_return('text/css')
        allow(File).to receive(:read).and_return('h1 { color: red }')
      end

      it { is_expected.to eq([200, { 'Content-Type' => 'text/css' }, ['h1 { color: red }']]) }
    end

    context 'when file is not available' do
      before { allow(static_dispatch).to receive(:file_available?).with('public/app.css').and_return(false) }

      it { is_expected.to eq([404, {}, ['Not found']]) }
    end

    context 'with inappropriate request type' do
      let(:env_options) do
        { 'REQUEST_METHOD' => 'POST' }
      end

      it { is_expected.to eq([400, {}, ['Bad request']]) }
    end
  end
end
