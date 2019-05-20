# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/spec'
require 'pry'

require 'minitest/reporters'
Minitest::Reporters.use!

# Set up MiniTest::Tagz, with stick-it-anywhere `:focus` support.
require 'minitest/tagz'
tags = ENV['TAGS'].split(',') if ENV['TAGS']
tags ||= []
tags << 'focus'
Minitest::Tagz.choose_tags(*tags, run_all_if_no_match: true)

require 'pry-byebug'

require_relative './image_item'

describe ImageItem do
  let(:default_hanami_model_version) { '1.3.2' }
  let(:default_hanami_version) { '1.3.1' }
  let(:default_image_version) { '9.99.0' }
  let(:default_maintainer) { 'Jeff Dickey <jdickey at seven-sigma dot com>' }
  let(:default_ruby_version) { '2.6.5' }
  let(:valid_params) do
    {
      base_os: 'slim-stretch',
      # Set :hanami_model_version to nil if no `hanami-model` Gem to be in image
      #   Otherwise, set to hanami-model Gem version; e.g., 1.3.2
      hanami_model_version: nil,
      hanami_version: default_hanami_version,
      image_version: default_image_version,
      ruby_version: default_ruby_version,
      tags: ['2.5-stretch-slim-no-hm', 'stretch-slim-no-hm']
    }
  end
  let(:item) { ImageItem.new(valid_params) }

  describe '#initialize' do
    describe 'requires parameters for' do
      it 'base_os' do
        valid_params.delete :base_os
        expect { item }.must_raise ArgumentError
      end

      it ':hanami_model_version' do
        valid_params.delete :hanami_model_version
        expect { item }.must_raise ArgumentError
      end

      it ':hanami_version' do
        valid_params.delete :hanami_version
        expect { item }.must_raise ArgumentError
      end

      it ':image_version' do
        valid_params.delete :image_version
        expect { item }.must_raise ArgumentError
      end

      it 'qt NOT in params' do
        valid_params.delete :qt
        expect(item).wont_be :nil?
      end

      it 'ruby_version' do
        valid_params.delete :ruby_version
        expect { item }.must_raise ArgumentError
      end

      it 'tags' do
        valid_params.delete :tags
        expect { item }.must_raise ArgumentError
      end
    end # describe 'requires parameters for'

    describe 'accepts parameters for' do
      it 'latest' do
        valid_params[:latest] = true
        obj = ImageItem.new valid_params
        expect(obj.latest?).must_equal true
      end
    end # describe 'accepts parameters for'

    it 'freezes the new object' do
      expect(item).must_be :frozen?
    end
  end # describe '#initialize'

  describe 'does not have reader methods for' do
    it 'qt?' do
      expect(item.respond_to?(:qt?)).must_equal false
    end
  end # describe 'does not have reader methods for'

  describe 'has reader methods for' do
    it 'base_os' do
      valid_params[:base_os] = 'some-other-string'
      expect(item.base_os).must_equal 'some-other-string'
    end

    it 'hanami_model_version' do
      valid_params[:hanami_model_version] = default_hanami_model_version
      expect(item.hanami_model_version).must_equal default_hanami_model_version
    end

    it 'hanami_version' do
      expect(item.hanami_version).must_equal default_hanami_version
    end

    describe 'hm?, such that when :hanami_model_version is initialised with' do
      it 'a valid string, the #hm? reader returns true' do
        valid_params[:hanami_model_version] = default_hanami_model_version
        expect(item.hm?).must_equal true
      end

      it 'an invalid string, the #hm? reader returns false' do
        valid_params[:hanami_model_version] = 'Not a SemVer String'
        expect(item.hm?).must_equal false
      end

      it 'nil, the #hm? reader returns false' do
        valid_params[:hanami_model_version] = nil
        expect(item.hm?).must_equal false
      end
    end # describe 'hm?, ... when :hanami_model_version is initialised with'

    it 'image_version' do
      expect(item.image_version).must_equal default_image_version
    end

    it 'ruby_version' do
      expect(item.ruby_version).must_equal default_ruby_version
    end

    describe 'tags' do
      it 'that returns a frozen array of strings' do
        expect(item.tags).must_be :frozen?
      end

      it 'when initialised with a single string, returns an array' do
        valid_params[:tags] = 'some-other-tag'
        expect(item.tags).must_equal ['some-other-tag']
      end
    end # 'tags'

    describe 'latest? such that' do
      it 'defaults to false' do
        obj = ImageItem.new valid_params
        expect(obj.latest?).must_equal false
      end

      it 'can be set to true' do
        valid_params[:latest] = true
        obj = ImageItem.new valid_params
        expect(obj.latest?).must_equal true
      end
    end # describe 'latest? such that'
  end # describe 'has reader methods for'

  describe '#build_tag_name' do
    it 'returns the correct build tag for the initialised parameters' do
      last_part = valid_params[:hanami_model_version].nil? ? 'no-hm' : 'hm'
      parts = [:ruby_version, :base_os].map { |part| valid_params[part] }
      parts << last_part
      expect(item.build_tag_name).must_equal parts.join('-')
    end
  end # describe '#build_tag_name'

  describe '#debian?' do
    describe 'returns true for a base_os value of' do
      after do
        expect(item.debian?).must_equal true
      end

      it 'slim-jessie' do
        valid_params[:base_os] = 'slim-jessie'
      end

      it 'slim-stretch' do
        valid_params[:base_os] = 'slim-stretch'
      end

      it 'jessie' do
        valid_params[:base_os] = 'jessie'
      end

      it 'stretch' do
        valid_params[:base_os] = 'stretch'
      end
    end # describe 'returns true for a base_os value of'

    describe 'returns false for a base_os value of' do
      after do
        expect(item.debian?).must_equal false
      end

      it 'alpine3.7' do
        valid_params[:base_os] = 'alpine3.7'
      end
    end # describe 'returns false for a base_os value of'
  end # describe '#debian?'

  describe '#alpine?' do
    describe 'returns false for a base_os value of' do
      after do
        expect(item.alpine?).must_equal false
      end

      it 'slim-jessie' do
        valid_params[:base_os] = 'slim-jessie'
      end

      it 'slim-stretch' do
        valid_params[:base_os] = 'slim-stretch'
      end

      it 'jessie' do
        valid_params[:base_os] = 'jessie'
      end

      it 'stretch' do
        valid_params[:base_os] = 'stretch'
      end
    end # describe 'returns false for a base_os value of'

    describe 'returns true for a base_os value of' do

      after do
        expect(item.alpine?).must_equal true
      end

      it 'alpine3.7' do
        valid_params[:base_os] = 'alpine3.7'
      end
    end # describe 'returns true for a base_os value of'
  end # describe '#alpine?'

  describe '#upgrade_cmd returns the correct string when the base_os is' do
    let(:alpine_upgrade) { 'apk --no-cache upgrade' }
    let(:debian_upgrade) do
      ['apt-get update -qq', 'apt-get dist-upgrade -y', 'apt-get clean',
       'find /var/lib/apt/lists/* -delete'
      ].join(' && ')
    end

    it '#alpine?' do
      valid_params[:base_os] = 'alpine3.7'
      expect(item.upgrade_cmd).must_equal alpine_upgrade
    end

    it '#debian?' do
      valid_params[:base_os] = 'stretch'
      expect(item.upgrade_cmd).must_equal debian_upgrade
    end
  end # describe '#upgrade_cmd returns the correct string when the base_os is'

  describe '#base_image_spec' do
    it 'does not include the -qt (or -no-qt) suffix' do
      valid_params.merge!(base_os: 'stretch')
      expect(item.base_image_spec).wont_include 'qt'
    end
  end # describe '#base_image_spec'

  describe '#maintainer' do
    describe 'by default' do
      it 'has the default :maintainer information' do
        expect(item.maintainer).must_equal default_maintainer
      end
    end # describe 'by default'

    it 'when initialised with a :maintainer param specified' do
      expected = 'Some Other Maintainer'
      valid_params[:maintainer] = expected
      expect(item.maintainer).must_equal expected
    end
  end # describe '#maintainer'
end
