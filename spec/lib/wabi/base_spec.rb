# frozen_string_literal: true

describe Wabi::Base do
  # subject(:base) { described_class.new() }

  # let(:app) { ->(_) { [200, {}, []] } }
  let(:env) { Rack::MockRequest.env_for(url, env_options) }
  let(:url) { '/some/url' }
  let(:env_options) { {} }
  let(:router) { instance_double(Wabi::Router) }

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

  describe '#call' do
  end
end
