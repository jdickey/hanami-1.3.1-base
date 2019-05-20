#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './build_tagged_image'
require_relative './image_list_builder'

# image_list = ImageListBuilder.new.call;

ImageListBuilder.new.call.each_pair do |name, data|
  # We sometimes get Docker timeouts when building; give up to three retries
  retries_left ||= 3
  begin
    BuildTaggedImage.new.call(name, data)
  rescue Docker::Error::TimeoutError
    retries_left -= 1
    print "retrying... " unless retries_left.zero?
    retry unless retries_left.zero?
    retries_left = nil
    puts "Aborting; timeouts exhausted"
  else
    retries_left = 3
    puts "complete!"
  end
end
