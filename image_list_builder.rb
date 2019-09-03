
require 'yaml';

require_relative './image_item'

class ImageListBuilder
  def initialize(yaml_file: './builds.yml')
    image_config_data = YAML.load_file(yaml_file);
    @builds = image_config_data['builds']
    @metadata = image_config_data['metadata'].transform_keys(&:to_sym)
  end

  def call
    Hash[traverse_builds.inject({}) do |list, (build_key, build_spec)|
      list.merge(build_key => ImageItem.new(build_spec))
    end]
  end

  private

  attr_reader :builds, :metadata

  def params_from(ruby_version, base_os, hm_key, per_hm)
    model_version = hm_key == 'hm' ? metadata[:hanami_model_version] : nil;
    metadata.to_h.merge(
      hanami_model_version: model_version,
      ruby_version: ruby_version,
      base_os: base_os,
      tags: per_hm['tags'],
      latest: per_hm['actual_latest'] || false
    )
  end

  def traverse_builds
    Hash[builds.inject({}) do |build_specs, (ruby_version, per_version)|
      build_specs.merge(traverse_per_version(per_version, ruby_version, metadata))
    end]
  end

  def traverse_per_base_os(per_base_os, base_os, ruby_version, metadata)
    Hash[per_base_os.inject({}) do |build_specs, (hm_key, per_hm)|
      new_key = "#{ruby_version}-#{base_os}-#{hm_key}"
      params = params_from(ruby_version, base_os, hm_key, per_hm)
      build_specs.merge(new_key => params)
    end]
  end

  def traverse_per_version(per_version, ruby_version, metadata)
    Hash[per_version.inject({}) do |build_specs, (base_os, per_base_os)|
      build_specs.merge(traverse_per_base_os(per_base_os, base_os, ruby_version, metadata))
    end]
  end
end # class ImageListBuilder
