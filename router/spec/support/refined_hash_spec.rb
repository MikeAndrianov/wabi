# frozen_string_literal: true

class DummyClass
  using Wabi::RefinedHash

  attr_accessor :some_field

  def test_deep_symbolizing
    some_field.deep_symbolize_keys
  end
end

describe Wabi::RefinedHash do
  let(:instance) { DummyClass.new }

  before { instance.some_field = { 'foo' => { 'bar' => 'baz' } } }

  it { expect(instance.test_deep_symbolizing).to eq({ foo: { bar: 'baz' } }) }
end
