# Rack::TrafficSignal

Rack::TrafficSignal is a Rack middleware to make application in maintenance mode.
You can make part of application in maintenance mode, and use different http status and response body.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-traffic-signal'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-traffic-signal

If you are installing this gem to Rails application, run:

    $ rails g rack_traffic_signal:install

## Usage

### Rails

Generator places initializer template and sample maintenance page.

Modify `config/initializers/rack_traffic_signal.rb` .

### Not Rails

Insert Rack::TrafficSignal::Middleware to Middleware stack manually, and create setting script.

## Setting

```ruby
Rack::TrafficSignal.setup do |config|
  # This config is used to internal_access? method.
  # Only add path to this option, mantenance mode is not skipped.
  config.internal_ips = ['192.168.1.1/25']

  # This config is used to skip_path? method.
  # Only add path to this option, mantenance mode is not skipped.
  config.skip_paths = [/^\/users\/12345/]

  # Default setting
  config.default_status = 503
  config.default_content_type = 'application/json'
  config.default_body = { error: 'error' }.to_json

  # Maintenance group settings
  # Maintenance group defined as :<resource>_<action>

  # If path defined by String, maintenance mode will be applied path is match rigidly.
  # '/users' does not make maintenance mode '/users/foo'.

  # If multiple setting is appliable, more general setting will be priored.
  # %{/} has higher priority than %{/users/\/d+/foo/bar}
  config.maintenance_group =   {
    # <resource>: {
    #   <action>: [
    #     { methods: [:get, :post], path: <path_to_maintenance>}
    #   ]
    # }
    users: {
      register: [
        { methods: [:get], path: "/users/new"},
        { methods: [:post], path: "/users" }
      ],
      update: [
        { methods: [:put], path: %r{/users/\d+}}
      ]
    }
  }

  # Block to judge whether requested page/api is under maintenance.
  # Returns Array<Symbol>
  # If status array include...
  #   :all => all of maintenance groups are enabled.
  #   :<resource>_all => maintenance groups under resource
  #     ex) :users_all => users_register and users_update are in under maintenance
  #  :<resource>_<action> => maintenance group matches is in under maintenance
  config.maintenance_status_by do
    ENV['MAINTENANCE_STATUS'] # [:users_register, :users_update]
  end

  # Block to judge whether maintenance mode should be skipped.
  # For example, you can skip maintenance mode with specific path or internal access.
  config.skip_by do |env|
    Rack::TrafficSignal.skip_path?(env) || Rack::TrafficSignal.internal_access?
  end

  # Block to judge whether maintenance mode should be skipped with warning.
  # For example, you can skip maintenance mode with specific path or internal access.
  # Warn by add 'X-RACK-TRAFFIC-SIGNAL-MAINTENANCE' to response header.
  config.skip_with_warning_by do |env|
    Rack::TrafficSignal.skip_path?(env) || Rack::TrafficSignal.internal_access?
  end
end
```

## Contributing

1. Fork it
1. Create your feature branch (git checkout -b my-new-feature)
1. Commit your changes (git commit -am 'Add some feature')
1. Push to the branch (git push origin my-new-feature)
1. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

