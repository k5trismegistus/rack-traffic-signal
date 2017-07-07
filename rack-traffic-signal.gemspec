# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/traffic_signal/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-traffic-signal"
  spec.version       = Rack::TrafficSignal::VERSION
  spec.authors       = ["keigo yamamoto"]
  spec.email         = ["k5.trismegistus@gmail.com"]

  spec.summary       = 'Traffic signal of rack application'
  spec.description   = 'Make your app maintenance mode. You can prohibit all/a part of external access'
  spec.homepage      = "https://github.com/k5trismegistus/rack-traffic-signal"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "ipaddress"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rack-test"
end
