#!/usr/bin/env ruby

require "thor"

class Db < Thor
  include Thor::Actions

  def self.exit_on_failure?
    true
  end

  desc "start", "Starts the db service"
  def start
    say "Starting db service"
    run("docker run --rm --detach --name postgres-container -p 5432:5432 -e POSTGRES_HOST_AUTH_METHOD=trust -d postgres:14.10", capture: true)
  end

  desc "stop", "Stops the db service"
  def stop
    say "Stopping db service"
    run("docker stop postgres-container", capture: true )
  end

end

Db.start(ARGV)
