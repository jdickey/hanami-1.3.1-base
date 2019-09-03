# frozen_string_literal: true

require 'test_helper.rb'

require_relative '../image_list_builder'

describe ImageListBuilder do
  describe 'with default #initialize parameters' do
    describe 'returns a non-empty Hash where' do
      subject { ImageListBuilder.new.call }

      it 'all keys are String instances' do
        expected = Set.new(subject.keys.map(&:class)).to_a
        expect([String]).must_equal expected
      end

      it 'all values are ImageItem instances' do
        expected = Set.new(subject.values.map(&:class)).to_a
        expect([ImageItem]).must_equal expected
      end
    end # describe 'returns a non-empty Hash where'
  end # describe 'with default #initialize parameters'

  tag :focus
  it 'does stuff' do
    obj = ImageListBuilder.new
    obj.call
  end
end

