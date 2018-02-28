require 'json'

module Rack
  module TrafficSignal
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        return @app.call(env) if Rack::TrafficSignal.skip?(env)
        method = env['REQUEST_METHOD'].downcase.to_sym
        path = env['PATH_INFO']
        path = path.chop if path != '/' && path[-1] == '/'

        applied_config = maintenance_application(method, path)

        if applied_config
          if Rack::TrafficSignal.skip_with_warning?(env)
            @app.call(env).tap do |status, headers, body|
              headers['X-RACK-TRAFFIC-SIGNAL-MAINTENENCE'] = '1'
            end
          else
            build_response(applied_config)
          end
        else
          @app.call(env)
        end
      end

      private

      def build_response(applied_config)
        status = applied_config[:status] ? applied_config[:status] : config.default_status
        content_type = applied_config[:content_type] ? applied_config[:content_type] : config.default_content_type
        body = applied_config[:body] ? applied_config[:body] : config.default_body
        header = { "Content-Type" => content_type, 'Content-Length' => body.bytesize.to_s }

        [status, header, [body]]
      end

      def config_appliable?(config, method, path)
        path_match = if config[:path].is_a?(String)
            path == config[:path]
          elsif config[:path].is_a? Regexp
            path.match(config[:path])
          else
            false
          end

        path_match && config[:methods].include?(method)
      end

      def path_length(path)
        if path.is_a? String
          path.split('/').length
        elsif path.is_a? Regexp
          path.source.split('/').length
        end
      end

      def maintenance_application(method, path)
        enabled_maintenance_mode = config.maintenance_status
        return nil if enabled_maintenance_mode.length == 0

        enabled_cfg = if enabled_maintenance_mode.include? :all
            config.maintenance_group.values.inject([]) do |a, p|
              a + p.values
            end
          else
            enabled_maintenance_mode.inject([]) do |a, mode|
              resource, action = *mode.to_s.split('_').map(&:to_sym)
              if action == :all
                a + config.maintenance_group[resource].values
              else
                a + config.maintenance_group[resource][action]
              end
            end
          end

        enabled_cfg.flatten!

        applied = enabled_cfg
          .uniq
          .select { |c| config_appliable?(c, method, path) }
          .sort { |a, b| path_length(a[:path]) <=> path_length(b[:path]) }
        if applied.length > 0
          return applied[0]
        else
          return nil
        end
      rescue NoMethodError
        raise Rack::TrafficSignal::Exceptions::InvalidMaintenanceGroup
      end

      def config
        Rack::TrafficSignal.config
      end
    end
  end
end