# frozen_string_literal: true

describe Wabi::Route do
  subject(:route) { described_class.new('GET', '/posts/:id', -> {}) }

  describe '#match?' do
    it { expect(route.match?('GET', '/posts/1')).to be_truthy }
    it { expect(route.match?('POST', '/posts/1')).to be_falsey }
  end

  it { expect(route.params_from_path('/posts/1')).to eq('id' => '1') }
end
