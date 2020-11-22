# frozen_string_literal: true

describe Wabi::ResourcesRoute do
  subject(:route) { described_class.new(:posts, excluded_actions) }

  let(:excluded_actions) { [] }

  describe '#initialize' do
    it 'creates default CRUD actions' do
      expect(route.actions.map(&:name)).to include(:index, :show, :new, :edit, :create, :update, :destroy)
    end

    context 'with excluded actions' do
      let(:excluded_actions) { %i[edit update delete] }

      it { expect(route.actions.map(&:name)).to include(:index, :show, :new, :create) }
    end
  end

  describe '#response' do
    let(:env) { {} }

    it { expect(route.response(env)).to eq([200, {}, []]) }
  end

  describe '#match?' do
    it { expect(route.match?('GET', '/posts')).to be_truthy }
    it { expect(route.match?('GET', '/posts/1')).to be_truthy }
    it { expect(route.match?('PATCH', '/posts/1')).to be_truthy }
    it { expect(route.match?('POST', '/posts/1')).to be_falsey }
  end
end
