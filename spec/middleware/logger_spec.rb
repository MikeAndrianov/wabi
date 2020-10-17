# frozen_string_literal: true

describe Middleware::Logger do
  subject(:logger) { described_class.new(app) }

  let(:app) { ->(_) { [200, {}, []] } }
  let(:env) { Rack::MockRequest.env_for(url, env_options) }
  let(:url) { '/some/url' }
  let(:env_options) { {} }
  let(:logger_instance) { spy('logger') }

  before do
    allow(DateTime).to receive(:now).and_return(DateTime.new(2020, 10, 16))
    allow(Logger).to receive(:new).and_return(logger_instance)
  end

  describe '#call' do
    it { expect(logger.call(env)).to eq([200, {}, []]) }

    context 'with stubbed Benchmark' do
      let(:benchmark_instance) { instance_double(Benchmark::Tms, real: 1) }

      before do
        allow(Benchmark).to receive(:measure).and_return(benchmark_instance)
        logger.call(env)
      end

      context 'with GET request' do
        it 'logs record with empty params' do
          expect(logger_instance)
            .to have_received(:info)
            .with(
              '2020-10-16T00:00:00+00:00: GET /some/url'\
              "\nparams: {}\n"\
              'Response Time: 1000 ms'
            )
        end

        context 'with query params' do
          let(:url) { '/some/url?q=search' }

          it 'logs record' do
            expect(logger_instance)
              .to have_received(:info)
              .with(
                '2020-10-16T00:00:00+00:00: GET /some/url'\
                "\nparams: {\"q\"=>\"search\"}\n"\
                'Response Time: 1000 ms'
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
          expect(logger_instance)
            .to have_received(:info)
            .with(
              '2020-10-16T00:00:00+00:00: POST /some/url'\
              "\nparams: {\"foo\"=>\"bar\", \"password\"=>\"[FILTERED]\"}\n"\
              'Response Time: 1000 ms'
            )
        end
      end
    end
  end
end
