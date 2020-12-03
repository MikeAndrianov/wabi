# frozen_string_literal: true

describe Wabi::Route do
  subject(:route) { described_class.new('GET', '/posts/:id', -> {}) }

  describe '#match?' do
    it { expect(route.match?('GET', '/posts/1')).to be_truthy }
    it { expect(route.match?('POST', '/posts/1')).to be_falsey }
  end

  describe '#params_for_request' do
    subject { described_class.new('GET', route_path, -> {}).params_for_request(request) }

    let(:env) { Rack::MockRequest.env_for(url) }
    let(:url) { '/some/url?q=search' }
    let(:route_path) { '/:slug/url' }
    let(:request) { Rack::Request.new(env) }

    it { is_expected.to include(slug: 'some', q: 'search') }

    context 'with id in url' do
      let(:url) { '/posts/1' }
      let(:route_path) { '/posts/:id' }

      it { is_expected.to eq(id: '1') }
    end
  end

end
