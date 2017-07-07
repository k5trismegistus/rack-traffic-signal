module RackTrafficSignal
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)
      desc 'Install Rack::TrafficSignal to Rails application'

      def install
        template 'initializer.rb', 'config/initializers/rack_traffic_signal.rb'
        template '503.html', 'public/503.html'
      end
    end
  end
end
