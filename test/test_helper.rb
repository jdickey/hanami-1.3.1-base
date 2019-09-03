# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  coverage_dir './tmp/coverage'
  add_filter '/tmp/'
  add_filter '/spec/' # We don't need to include coverage of *specs*!
end

require 'minitest/autorun'
require 'minitest/hooks/default'
require 'minitest/spec'
require 'pry-byebug'

require 'minitest/reporters'
Minitest::Reporters.use!

# Set up MiniTest::Tagz, with stick-it-anywhere `:focus` support.
require 'minitest/tagz'
tags = ENV['TAGS'].split(',') if ENV['TAGS']
tags ||= []
tags << 'focus'
Minitest::Tagz.choose_tags(*tags, run_all_if_no_match: true)
