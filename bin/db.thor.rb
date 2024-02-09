#!/usr/bin/env ruby

require "thor"

class Db < Thor
  include Thor::Actions

  def self.exit_on_failure?
    false
  end

  desc "start", "Starts the db service"
  def start
    say "Starting db service"

    run("docker network create notes-bridge-docker-network", capture: true)
    run("docker volume create notes-data-volume", capture: true)

    # --publish 5432:5432 \

    run(
      <<~CMD.gsub(/\s+/, " ").strip,
        docker run --rm --detach --name notes-db \
          --env POSTGRES_HOST_AUTH_METHOD=trust \
          --network notes-bridge-docker-network \
          --env PGDATA=/var/lib/postgresql/data/pgdata \
          -v notes-data-volume:/var/lib/postgresql/data:delegated \
          postgres:14.10
      CMD
      capture: true
    )
  end

  desc "stop", "Stops the db service"
  def stop
    say "Stopping db service"
    run("docker stop notes-db", capture: true )
  end

end

Db.start(ARGV)
