# frozen_string_literal: true

describe Middleware::ErrorHandler do
  let(:env) { Rack::MockRequest.env_for('/some/url') }

  describe '#call' do
    subject { described_class.new(app).call(env) }
    let(:app) { ->(_) { [200, {}, []] } }

    context 'when exception was raised' do
      let(:app) { ->(_) { raise exception } }
      let(:exception) { StandardError.new('Error!') }

      before { allow(exception).to receive(:backtrace).and_return(%w[stack trace]) }

      it { is_expected.to eq([500, {}, ['Something went wrong']]) }

      context 'with trace' do
        subject { described_class.new(app, show_trace: true).call(env) }

        it { is_expected.to eq([500, {}, %w[stack trace]]) }
      end
    end

    context 'when flow without exceptions' do
      before { allow(app).to receive(:call).with(env) }

      it 'continues execution' do
        is_expected
        expect(app).to have_received(:call).with(env)
      end
    end
  end
end
