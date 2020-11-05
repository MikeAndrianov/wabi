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

  describe '#call' do
    subject { described_class.new.call(env) }

    let(:env) { Rack::MockRequest.env_for(url) }

    before { allow(router).to receive(:find_response).with('GET', url).and_return(->(_env) { [200, {}, ['Hello']] }) }

    it { is_expected.to eq([200, {}, ['Hello']]) }
  end
end
