# frozen_string_literal: true

class ImageItem
  def initialize(base_os:, hanami_model_version:, hanami_version:,
                 image_version:, ruby_version:, tags:, latest: false,
                 maintainer: DEFAULT_MAINTAINER)
    @base_os = base_os
    # Leave @hanami_model_version as nil unless a valid SemVer string supplied
    if hanami_model_version.to_s.match?(/^\d+\.\d+(\.\d+){0,1}/)
      @hanami_model_version = hanami_model_version
    end
    @hanami_version = hanami_version
    @image_version = image_version
    @latest = !!latest
    @maintainer = maintainer
    @ruby_version = ruby_version
    @tags = Array(tags)
    @tags.freeze
    freeze
  end

  attr_reader :base_os, :hanami_model_version, :hanami_version, :image_version,
              :maintainer, :ruby_version, :tags

  def alpine?
    base_os.match?(/^alpine/)
  end

  def base_image_spec
    "#{BASE_REPO}:#{ruby_version}-#{base_os}"
  end

  def build_tag_name(delimiter: '-')
    suffix = hm? ? 'hm' : 'no-hm'
    [ruby_version, base_os, suffix].join(delimiter)
  end

  def debian?
    DEBIAN_OS_NAMES.include? base_os
  end

  def hm?
    !hanami_model_version.nil?
  end

  def latest?
    @latest
  end

  def upgrade_cmd
    return 'apk --no-cache upgrade' if alpine?
    ['apt-get update -qq', 'apt-get dist-upgrade -y', 'apt-get clean',
     'find /var/lib/apt/lists/* -delete'].join(' && ')
  end

  BASE_REPO = 'jdickey/ruby'
  DEBIAN_OS_NAMES = %w(slim-stretch stretch).freeze
  DEFAULT_MAINTAINER = 'Jeff Dickey <jdickey at seven-sigma dot com>'
end # class ImageItem
