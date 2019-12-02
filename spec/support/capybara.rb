# Register firefox driver; all others are included by default
# https://github.com/teamcapybara/capybara/blob/master/README.md#selenium
Capybara.register_driver :selenium_firefox do |app|
  Capybara::Selenium::Driver.new(app, browser: :firefox)
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    if ENV['DRIVER']
      case ENV['DRIVER'].to_sym
      when :chrome
        driven_by :selenium_chrome
      when :firefox
        driven_by :selenium_firefox
      end
    else
      driven_by :selenium_headless
    end
  end
end
