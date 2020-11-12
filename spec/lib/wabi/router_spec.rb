# frozen_string_literal: true

describe Wabi::Router do
  subject(:router) { Class.new(described_class).instance }

  before { router.routes = [] }

  describe '#add_route' do
    it { expect { router.add_route('POST', '/test', -> {}) }.to change { router.routes.count }.from(0).to(1) }

    it 'creates route with specific structure' do
      router.add_route('GET', '/', -> {})
      route = router.routes[0]

      expect(route).to be_a(Wabi::Route)
      expect(route.http_verb).to eq('GET')
      expect(route.path).to eq('/')
      expect(route.response).to be_a(Proc)
    end
  end

  describe '#find_route' do
    before { router.add_route('POST', '/test', -> {}) }

    it { expect(router.find_route('POST', '/test')).to be_a(Wabi::Route) }
    it { expect(router.find_route('GET', '/test')).to be_nil }
  end
end
