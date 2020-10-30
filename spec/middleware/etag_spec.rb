# frozen_string_literal: true

describe Middleware::Etag do
  subject(:etag) { described_class.new(app) }

  let(:app) { ->(_) { [200, headers, ['Hello world']] } }
  let(:headers) { {} }
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

      context 'with etag has been already set' do
        let(:headers) do
          {
            'ETag' => 'hlwrld',
            'Cache-Control' => 'max-age=18000, private',
            'Last-Modified' => last_modified
          }
        end
        let(:last_modified) { 'Thu, 29 Oct 2020 22:12:46 +0100' }

        it { expect(response[0]).to eq(304) }
        it { expect(response[2]).to eq([]) }

        it 'returns specific headers without modification' do
          expect(response[1])
            .to include(
              'Cache-Control' => 'max-age=18000, private',
              'ETag' => 'hlwrld',
              'Last-Modified' => last_modified
            )
        end
      end
    end
  end
end
