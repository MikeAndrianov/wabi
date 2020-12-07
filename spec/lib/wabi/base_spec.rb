# frozen_string_literal: true

describe Wabi::Base do
  subject(:app_instance) { described_class.new }

  let(:url) { '/some/url' }
  let(:router) { app_instance.router }

  describe '#call' do
    subject { app_instance.call(env) }

    let(:env) { Rack::MockRequest.env_for(url) }

    before { router.get(url) { 'Hello' } }

    it { is_expected.to eq([200, {}, ['Hello']]) }

    context 'when mounted route' do
      let(:mounted) { spy('mount') }
      let(:url) { '/some/another-url' }
      let(:route) { Wabi::MountRoute.new('/some', mounted) }

      before { allow(mounted).to receive(:call).and_return([200, {}, ['Hello']]) }

      it { is_expected.to eq([200, {}, ['Hello']]) }
    end

    context 'when route is not found' do
      let(:env) { Rack::MockRequest.env_for(url, method: 'POST') }

      it { is_expected.to eq([404, {}, ['Not Found']]) }
    end
  end
end
