require 'ipaddress'

module Rack
  module TrafficSignal
    class Config

      attr_reader   :maintenance_group
      attr_accessor :internal_ips,
                    :skip_paths,
                    :default_status,
                    :default_content_type,
                    :default_body,
                    :secret_word,
                    :skip_proc,
                    :skip_with_warning_proc

      def initialize
        @internal_ips = []
        @maintenance_group = { }
        @default_status = 503
        @default_content_type = 'application/json'
        @default_body = ''
        @secret_word = ''
        @skip_paths = [/^\/assets/]
        @maintenance_status_proc = ->{ [] }
        @skip_proc = ->(env){ false }
        @skip_with_warning_proc = ->(env){ false }
      end

      def maintenance_group=(mg)
        raise Rack::TrafficSignal::Exceptions::InvalidMaintenanceGroup unless valid_maintenance_group?(mg)
        @maintenance_group = mg
      end

      def maintenance_status_by(&block)
        @maintenance_status_proc = block
      end

      def maintenance_status
        @maintenance_status_proc.call.tap do |status|
          raise Rack::TrafficSignal::Exceptions::InvalidMaintenanceStatus unless status.is_a? Array
          raise Rack::TrafficSignal::Exceptions::InvalidMaintenanceStatus unless status.all? do |state|
            state.is_a?(Symbol) && (state == :all || state.to_s =~ /\A[A-Za-z0-9]+_[A-Za-z0-9]+\z/)
          end
        end
      end

      def skip_by(&block)
        @skip_proc = block
      end

      def skip_with_warning_by(&block)
        @skip_with_warning_proc = block
      end

      private
      def valid_maintenance_group?(mg)
        return false unless mg.is_a? Hash

        mg.values.each do |group|
          return false unless group.is_a? Hash
          group.values.each do |igroup|
            return false unless igroup.is_a? Array
            igroup.each do |setting|
              return false unless setting.key?(:methods)
              return false unless setting.key? :path
            end
          end
        end

        true

      rescue
        false
      end
    end
  end
end
