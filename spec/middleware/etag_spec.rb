# frozen_string_literal: true

describe Middleware::Etag do
  subject(:etag) { described_class.new(app) }

  let(:app) { ->(_) { [200, {}, ['Hello world']] } }
  let(:env) { Rack::MockRequest.env_for('/', env_options) }
  let(:env_options) { {} }

  describe '#call' do
    subject(:response) { etag.call(env) }

    before { allow(Digest::SHA256).to receive(:hexdigest).with('Hello world').and_return('hlwrld') }

    shared_examples 'returns full response' do
      it { expect(response[0]).to eq(200) }
      it { expect(response[1]).to include('Cache-Control' => 'max-age=36000, public', 'ETag' => 'hlwrld') }
      it { expect(response[2]).to eq(['Hello world']) }
    end

    context 'when request does not have etag' do
      include_examples 'returns full response'
    end

    context 'when request has invalid etag' do
      let(:env_options) { { 'HTTP_IF_NONE_MATCH' => 'hl' } }

      include_examples 'returns full response'
    end

    context 'when request has valid etag' do
      let(:env_options) { { 'HTTP_IF_NONE_MATCH' => 'hlwrld' } }

      it { expect(response[0]).to eq(304) }
      it { expect(response[1]).to eq({}) }
      it { expect(response[2]).to eq([]) }
    end
  end
end
