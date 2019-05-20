#!/usr/bin/env ruby
# frozen_string_literal: true

# Hyper-primitive Ruby adaptation of 'push-all.sh', using the Docker Ruby API.
# No error-detection or -handling (yet); basic AF, but it works.
#
# This script depends on three environment variables being set:
# - 'DOCKER_API_USERNAME' must be your username on Docker Hub
# - 'DOCKER_API_PASSWORD' must be the password associated with that username
# - 'DOCKER_API_EMAIL' must be the email address associated with that username.

# Again, this script
# - has no error handling for the Docker API
# - has no intelligent parsing/reporting for the Docker API data
# - is a single imperative stream of statements;
# - builds each image. Fortunately, if the image already exists locally, that's
#   basically a no-op, but still, it's sloppy.

# Three hours' work while physically exhausted using a poorly-documented layer
# over a published API. PRs welcome.

require_relative './build_tagged_image';
require_relative './image_list_builder'

username = ENV['DOCKER_API_USERNAME']
password = ENV['DOCKER_API_PASSWORD']
email = ENV['DOCKER_API_EMAIL']

raise 'Must specify DOCKER_API_USERNAME' unless username
raise 'Must specify DOCKER_API_PASSWORD' unless password
raise 'Must specify DOCKER_API_EMAIL' unless email

serveraddress = 'https://index.docker.io/v1'
credentials = { username: username, password: password, email: email,
                serveraddress: serveraddress }

list = ImageListBuilder.new.call;
push_results = []
progress_json = []

list.keys.sort.map do |image_name|
  image = BuildTaggedImage.new.call(image_name, list[image_name])
  image.info['RepoTags'].map do |repo_tag|
    push_results << image.push(credentials, repo_tag: repo_tag) do |json_text|
      json_text.lines.map do |json|
        progress_json << JSON.parse(json, symbolize_names: true)
      end
    end
  end
end
