#!/usr/bin/env ruby

require "thor"

require 'dotenv'
Dotenv.load('.env.development')

class Web < Thor
  include Thor::Actions

  def self.exit_on_failure?
    false
  end

  desc "build", "Builds the app"
  def build
    say "Building the app"
    run("docker build -t notes .", capture: true)

    run("docker network create notes-bridge-docker-network", capture: true)
  end

  desc "start", "Starts the app"
  def start
    say "Starting the app"
    run(
      <<~CMD.gsub(/\s+/, " ").strip,
        docker run --rm --name notes-web \
          --publish 3000:3000 \
          --env POSTGRES_HOST_AUTH_METHOD=trust \
          --env DATABASE_URL=postgres://postgres@notes-db:5432/notes_development \
          --env RAILS_ENV=development \
          --env RACK_ENV=development \
          --env RAILS_LOG_TO_STDOUT=true \
          --env RAILS_SERVE_STATIC_FILES=true \
          --env RAILS_MASTER_KEY=#{ENV["RAILS_MASTER_KEY"]} \
          --network notes-bridge-docker-network \
          -v #{Dir.pwd}/app:/rails/app:delegated \
          -v #{Dir.pwd}/config:/rails/config:delegated \
          -v #{Dir.pwd}/lib:/rails/lib:delegated \
          -v #{Dir.pwd}/bin:/rails/bin:delegated \
          -v #{Dir.pwd}/db:/rails/db:delegated \
          -v #{Dir.pwd}/spec:/rails/spec:delegated \
          notes:latest
      CMD
      capture: false
    )
  end
end

Web.start(ARGV)
