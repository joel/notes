# frozen_string_literal: true

module ExtendScaffoldGenerator
  extend ActiveSupport::Concern

  def invoke_all
    super # This runs the default scaffold generation
    invoke_extra_generators
  end

  def invoke_extra_generators
    generate "rspec:system", name, *attributes
  end
end

Rails.application.config.after_initialize do
  require "rails/generators/rails/scaffold_controller/scaffold_controller_generator"
  Rails::Generators::ScaffoldControllerGenerator.include ExtendScaffoldGenerator
end
