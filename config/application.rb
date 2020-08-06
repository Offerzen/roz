require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Roz
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.time_zone = "Africa/Johannesburg"
    config.generators do |g|
      g.orm                :active_record
      g.template_engine    :slim
      g.test_framework     :rspec, fixture: true
      g.javascript_engine  :js
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
		Money.locale_backend = nil
    Money.rounding_mode = BigDecimal::ROUND_HALF_UP
  end
end
