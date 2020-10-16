# frozen_string_literal: true

describe Middleware::Logger do
  subject(:logger) { described_class.new(app) }

  let(:app) { instance_double(App) }
  let(:env) { Rack::MockRequest.env_for(url, env_options) }
  let(:url) { '/some/url' }
  let(:env_options) { {} }
  let(:file_instance) { instance_double(File) }

  before do
    allow(FileUtils).to receive(:mkdir_p)
    allow(File).to receive(:open).and_return(file_instance)
    allow(File).to receive(:directory?).and_return(true)
    allow(DateTime).to receive(:now).and_return(DateTime.new(2020, 10, 16))

    allow(file_instance).to receive(:write)
    allow(file_instance).to receive(:close)
  end

  describe '#call' do
    before do
      allow(app).to receive(:call).with(env)

      logger.call(env)
    end

    context 'with GET request' do
      it 'writes record into file' do
        expect(File).to have_received(:open).with('logs/production.log', 'a')
      end

      it 'logs record with empty params' do
        expect(file_instance).to have_received(:write).with("2020-10-16T00:00:00+00:00: GET /some/url\nparams: {}\n\n")
      end

      context 'with query params' do
        let(:url) { '/some/url?q=search' }

        it 'logs record' do
          expect(file_instance)
            .to have_received(:write)
            .with(
              '2020-10-16T00:00:00+00:00: GET /some/url'\
              "\nparams: {\"q\"=>\"search\"}\n\n"
            )
        end
      end
    end

    context 'with POST request' do
      let(:env_options) do
        {
          'REQUEST_METHOD' => 'POST',
          input: { foo: 'bar', password: 'secret' }.to_json
        }
      end

      it 'logs record' do
        expect(file_instance)
          .to have_received(:write)
          .with(
            '2020-10-16T00:00:00+00:00: POST /some/url'\
            "\nparams: {\"foo\"=>\"bar\", \"password\"=>\"[FILTERED]\"}\n\n"
          )
      end
    end
  end
end
