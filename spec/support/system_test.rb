# frozen_string_literal: true

# https://github.com/teamcapybara/capybara?tab=readme-ov-file#configuring-and-adding-drivers
# https://github.com/SeleniumHQ/selenium/wiki/Ruby-Bindings#chrome
# https://peter.sh/experiments/chromium-command-line-switches/

# Warning: Rack::Handler is deprecated and replaced by Rackup::Handler
# Should be fixed in the next Capybara version
# https://github.com/teamcapybara/capybara/issues/2705
# Current version: capybara (3.39.2)

unless Gem.loaded_specs["capybara"].version.to_s == "3.39.2"
  raise "Capybara seems to updated, so please remove this monkey patch #{__FILE__}:#{__LINE__} the warning should be fixed."
  # Warning: Rack::Handler is deprecated and replaced by Rackup::Handler
end

# Start: Monkey patch to fix the warning
require "rackup"
module Rack
  Handler = ::Rackup::Handler
end
# End: Monkey patch to fix the warning

Capybara.register_driver :custom_driver do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  # Adds the --disable-gpu argument to Chrome options. This is primarily used to help in environments
  # where there is no GPU (like some CI servers), as Chrome otherwise uses GPU for rendering by default.
  options.add_argument("--disable-gpu")

  # Adds the --no-sandbox argument. This is often used when running Chrome in containerized environments
  # like Docker, where the sandbox security feature can cause issues. However, it's important to be aware
  # that using --no-sandbox can make Chrome less secure.
  options.add_argument("--no-sandbox")

  # When you add --disable-dev-shm-usage to Chrome's options, it makes Chrome use the /tmp directory instead
  # for its shared memory requirements. The /tmp directory usually has more space available than /dev/shm
  # in containerized environments.
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--window-size=400,800")

  args = {
    browser: :chrome,
    options:
  }

  Capybara::Selenium::Driver.new app, **args
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    if ENV["CI"].present?
      driven_by :selenium, using: :headless_chrome
    else
      driven_by :custom_driver
    end
  end
end
