#!/usr/bin/env ruby

require "thor"

class App < Thor
  include Thor::Actions

  def self.exit_on_failure?
    true
  end

  SERVICE_LIST = %w[db]
  private_constant :SERVICE_LIST

  class_option :force, type: :boolean, default: false

  argument :cmd, type: :string, required: true, desc: "Action to perform"

  desc "services", "Administer services"
  def services
    service_list.each do |service|
      run("bin/#{service} #{cmd}", capture: true)
    end
  end

  private

  def service_list
    SERVICE_LIST
  end

end

App.start(ARGV)

