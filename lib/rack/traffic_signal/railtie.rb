module Rack
  module TrafficSignal
    class Railtie < ::Rails::Railtie
      initializer 'insert_middleware' do |app|
        app.config.middleware.use Rack::TrafficSignal::Middleware
      end
    end
  end
end
