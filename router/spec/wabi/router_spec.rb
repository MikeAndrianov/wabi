# frozen_string_literal: true

describe Wabi::Router do
  subject(:router) { described_class.new }

  shared_examples 'adds a new route' do |http_verb|
    let(:url) { '/some/url' }
    let(:upcased_http_verb) { http_verb.upcase }

    it 'creates route with a specific structure' do
      router.public_send(http_verb, url) { }
      route = router.routes[0]

      expect(route).to be_a(Wabi::Route)
      expect(route.http_verb).to eq(upcased_http_verb)
      expect(route.path).to eq('/some/url')
      expect(route.response).to be_a(Proc)
    end
  end

  describe '.get' do
    include_examples 'adds a new route', 'get'
  end

  describe '.post' do
    include_examples 'adds a new route', 'post'
  end

  describe '#resources' do
    it { expect { router.resources(:posts) }.to change { router.resources_routes.count }.from(0).to(1) }
  end

  describe '.mount' do
    let(:mount) { Class.new }
    let(:path) { '/some' }

    it 'initializes mount route' do
      expect(Wabi::MountRoute).to receive(:new).with(path, mount)

      router.mount(path, mount)
    end

    it { expect { router.mount('/test', mount) }.to change { router.mount_routes.count }.from(0).to(1) }
  end

  describe '#find_route' do
    before { router.post('/test') }

    it { expect(router.find_route('POST', '/test')).to be_a(Wabi::Route) }
    it { expect(router.find_route('GET', '/test')).to be_nil }
  end
end
