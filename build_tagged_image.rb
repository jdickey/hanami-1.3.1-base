
require 'docker'

require_relative './dockerfile_builder'

class BuildTaggedImage
  def initialize(repo_name = 'jdickey/hanami-1.3.1-base')
    @repo_name = repo_name
  end

  def call(image_name, image_data)
    print "Building image for #{image_name}... "
    docker_image = Docker::Image.build(dockerfile(image_data))
    puts 'done!'
    docker_image.tag(repo: repo_name, tag: image_name)
    docker_image.tag(repo: repo_name, tag: 'latest') if image_data.latest?
    image_data.tags.each { |tag| docker_image.tag(repo: repo_name, tag: tag) }
    docker_image
  end

  private

  attr_reader :repo_name

  def dockerfile(image_data)
    DockerfileBuilder.call(config: image_data)
  end
end # BuildTaggedImage
