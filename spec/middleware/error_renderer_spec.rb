# frozen_string_literal: true

describe Middleware::ErrorRenderer do
  let(:env) { Rack::MockRequest.env_for('/some/url') }

  describe '#call' do
    subject { described_class.new(app).call(env) }

    let(:app) { ->(_env) { [status, {}, []] } }
    let(:status) { 404 }
    let(:file_instance) do
      instance_double(
        Middleware::Utils::Files,
        find: is_found,
        mime_type: 'text/html',
        body: file_body
      )
    end
    let(:is_found) { true }
    let(:file_body) { '<html>404</html>' }

    before do
      allow(Middleware::Utils::Files)
        .to receive(:new)
        .with('public/404.html')
        .and_return(file_instance)
    end

    it { is_expected.to eq([404, { 'Content-Type' => 'text/html' }, ['<html>404</html>']]) }

    context 'when static file is not available' do
      let(:is_found) { false }

      it { is_expected.to eq([404, {}, ['Not Found']]) }
    end

    context 'when 500 error' do
      let(:status) { 500 }
      let(:file_body) { '<html>500</html>' }

      before do
        allow(Middleware::Utils::Files)
          .to receive(:new)
          .with('public/500.html')
          .and_return(file_instance)
      end

      it { is_expected.to eq([500, { 'Content-Type' => 'text/html' }, ['<html>500</html>']]) }
    end
  end
end
