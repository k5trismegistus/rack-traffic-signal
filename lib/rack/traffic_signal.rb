require 'rack/traffic_signal/version'
require 'rack/traffic_signal/config'
require 'rack/traffic_signal/exceptions'
require 'rack/traffic_signal/middleware'
require 'rack/traffic_signal/railtie' if defined? Rails

module Rack
  module TrafficSignal
    def self.setup
      yield(config)
    end

    def self.config
      @config ||= Config.new
    end

    def self.skip?(env)
      config.skip_proc.call(env)
    end

    def self.skip_with_warning?(env)
      config.skip_with_warning_proc.call(env)
    end

    def self.internal_access?(env)
      remote_ip = IPAddress(request_from(env))
      config.internal_ips
        .map { |internal_ip| IPAddress(internal_ip) }
        .any? { |internal_ip| internal_ip.include?(remote_ip) if remote_ip.class == internal_ip.class }
    end

    def self.skip_path?(env)
      path = env['PATH_INFO']
      path = path.chop if path[-1] == '/'
      config.skip_paths.any? do |skip_path|
        if skip_path.is_a? Regexp
          path.match(skip_path)
        elsif skip_path.is_a? String
          path == skip_path
        else
          false
        end
      end
    end

    private
    def self.request_from(env)
      return env['REMOTE_ADDR'] unless env['HTTP_X_FORWARDED_FOR']
      env['HTTP_X_FORWARDED_FOR'].split(/,/)[0].strip
    end
  end
end
