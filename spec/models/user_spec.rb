# Source: https://github.com/rspec/rspec-rails/blob/6-1-maintenance/lib/generators/rspec/model/templates/model_spec.rb
require "rails_helper"

RSpec.describe User do
  it "is valid with valid attributes" do
    expect(described_class.new).to be_valid
  end
end
