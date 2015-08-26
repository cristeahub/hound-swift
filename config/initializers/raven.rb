require "sentry-raven"

Raven.configure do |config|
  config.dsn = ENV.fetch("SENTRY_DSN")
  config.environments = ["staging", "production"]
  config.current_environment = ENV.fetch("RACK_ENV")
end

module Raven
  class Client
    alias_method :original_send_event, :send_event
    def send_event(event)
      unless configuration.send_in_current_environment?
        log_event_details(event)
      end

      original_send_event(event)
    end

    def log_event_details(event)
      Raven.logger.debug("Event: #{event.message}")
    end
  end
end
