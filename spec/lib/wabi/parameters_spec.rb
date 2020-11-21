# frozen_string_literal: true

describe Wabi::Parameters do
  describe '#get' do
    subject { described_class.get(route, request) }

    let(:request) { Rack::Request.new(env) }
    let(:env) { Rack::MockRequest.env_for(url) }
    let(:url) { '/some/url?q=search' }
    let(:route) { instance_double(Wabi::Route) }

    before { allow(route).to receive(:params_from_path).with('/some/url').and_return(slug: 'some') }

    it { is_expected.to include(slug: 'some', q: 'search') }
  end
end
