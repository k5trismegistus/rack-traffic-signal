# -*- coding: utf-8 -*-

Rack::TrafficSignal.setup do |config|
  # config.internal_ips = []
  # config.default_status = 503
  # config.default_content_type = 'application/json'
  # require 'json'
  # config.default_body = '{}'.to_json
  # config.maintenance_group = {
  #     users: {
  #       read: [
  #         { methods: [:get], path: '/api/users', status: 404 },
  #         { methods: [:get], path: %r{/api/users/\d+}, status: 404, content_type: 'application/json' },
  #       ],
  #       write: [
  #         { methods: [:post], path: '/api/users' body: { error: 'maintenance mode' }.to_json },
  #         { methods: [:put, :delete], path: '%r{/api/users/\d+}' }
  #       ]
  #     },
  #     articles: {
  #       read: [
  #         { methods: [:get], path: '/api/articles' },
  #         { methods: [:get], path: %r{/api/articles/\d+} },
  #       ],
  #       write: [
  #         { methods: [:post], path: '/api/articles' },
  #         { methods: [:put, :delete], path: '%r{/api/articles/\d+}' }
  #       ]
  #     },
  #   }
  # config.maintenance_status_by do
  #   [:users_all, :articles_write]
  # end
  # config.skip_by do |env|
  #   false
  # end
end