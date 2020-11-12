# frozen_string_literal: true

describe Wabi::Base do
  let(:router) { instance_double(Wabi::Router) }
  let(:url) { '/some/url' }

  before do
    allow(Wabi::Router).to receive(:instance).and_return(router)
    allow(router).to receive(:add_route)
  end

  shared_examples 'adds a new route' do |http_verb|
    before { described_class.public_send(http_verb, url) }

    it { expect(router).to have_received(:add_route).with(http_verb.upcase, url, nil) }
  end

  describe '.get' do
    include_examples 'adds a new route', 'get'
  end

  describe '.post' do
    include_examples 'adds a new route', 'post'
  end

  describe '.mount' do
    let(:mount) { Class.new }
    let(:path) { '/some' }

    before do
      allow(router).to receive(:add_mount_route).with(path, mount)
      described_class.mount(path, mount)
    end

    it { expect(router).to have_received(:add_mount_route).with(path, mount) }
  end

  describe '#call' do
    subject { described_class.new.call(env) }

    let(:env) { Rack::MockRequest.env_for(url) }
    let(:route) { Wabi::Route.new('GET', url, ->(_env) { [200, {}, ['Hello']] }) }

    before { allow(router).to receive(:find_route).with('GET', url).and_return(route) }

    it { is_expected.to eq([200, {}, ['Hello']]) }

    context 'when mounted route' do
      let(:mounted) { spy('mount') }
      let(:url) { '/some/another-url' }
      let(:route) { Wabi::MountRoute.new('/some', mounted) }

      before { allow(mounted).to receive(:call).and_return([200, {}, ['Hello']]) }

      it { is_expected.to eq([200, {}, ['Hello']]) }
    end

    context 'when route is not found' do
      before { allow(router).to receive(:find_route).with('GET', url) }

      it { is_expected.to eq([404, {}, ['Not Found']]) }
    end
  end
end
