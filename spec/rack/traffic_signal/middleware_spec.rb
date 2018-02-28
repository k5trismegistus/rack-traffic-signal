require 'spec_helper'
include Rack::Test::Methods

describe  Rack::TrafficSignal::Middleware do
  let(:path) { '/' }
  let(:app_response_body) { '<body>Hello, World</body>' }
  let(:app) do
    builder = Rack::Builder.new
    builder.use Rack::Lint
    builder.use Rack::TrafficSignal::Middleware
    builder.run ->(env){
      yield env if block_given?
      [200, { 'Content-Type' => 'text/html' }, [app_response_body]]
    }
    builder.to_app
  end

  before { Rack::TrafficSignal.instance_variable_set('@config', nil) }

  subject do
    get path
    last_response
  end

  describe 'Invalid maintenance mode setting' do
    context 'when mantenance group key is not found' do
      before do
        Rack::TrafficSignal.setup do |config|
          config.maintenance_status_by do
            [:aaa_bbb]
          end
          config.maintenance_group = {
            foo: { bar: [ { methods: [:get], path: path } ] }
          }
        end
      end

      it { expect { subject }.to raise_error(Rack::TrafficSignal::Exceptions::InvalidMaintenanceGroup) }
    end

    context 'when mantenance group key is invalid' do
      before do
        Rack::TrafficSignal.setup do |config|
          config.maintenance_status_by do
            [:aaa_bbb_ccc]
          end
          config.maintenance_group = {
            foo: { bar: [ { methods: [:get], path: path } ] }
          }
        end
      end

      it { expect { subject }.to raise_error(Rack::TrafficSignal::Exceptions::InvalidMaintenanceStatus) }
    end
  end

  describe 'Not in maintenance mode' do
    context 'when maintenance status returns empty list' do
      before do
        Rack::TrafficSignal.setup do |config|
          config.maintenance_status_by do
            []
          end
          config.maintenance_group = {
            foo: { bar: [ { methods: [:get], path: path } ] }
          }
        end
      end

      it 'should return application response' do
        expect(subject.status).to eq(200)
      end
    end

    context 'when maintenance group is empty' do
      before do
        Rack::TrafficSignal.setup do |config|
          config.maintenance_status_by do
            [:all]
          end
          config.maintenance_group = { }
        end
      end

      it 'should return application response' do
        expect(subject.status).to eq(200)
      end
    end

    context 'when request is not in enabled maintenance group' do
      before do
        Rack::TrafficSignal.setup do |config|
          config.maintenance_status_by do
            [:foo_bar]
          end
          config.maintenance_group = {
            foo: { bar: [ { methods: [:get], path: '/foo' } ] }
          }
        end
      end

      it 'should return application response' do
        expect(subject.status).to eq(200)
      end
    end
  end

  describe 'Skipping maintenance mode' do
    context 'skip? returned true' do
      before do
        Rack::TrafficSignal.setup do |config|
          config.maintenance_status_by do
            [:all]
          end
          config.maintenance_group = {
            foo: { bar: [ { methods: [:get], path: path } ] }
          }
          config.skip_by do
            true
          end
        end
      end

      it 'should return application response' do
        expect(subject.status).to eq(200)
      end
    end
  end

  describe 'Skipping maintenance mode with warning' do
    context 'skip? returned true' do
      before do
        Rack::TrafficSignal.setup do |config|
          config.maintenance_status_by do
            [:all]
          end
          config.maintenance_group = {
            foo: { bar: [ { methods: [:get], path: path } ] }
          }
          config.skip_with_warning_by do
            true
          end
        end
      end

      it 'should return application response with warning' do
        expect(subject.status).to eq(200)
        expect(subject.header.key?("X-RACK-TRAFFIC-SIGNAL-MAINTENENCE")).to be_truthy
      end
    end
  end

  describe 'In maintenance mode' do
    context 'when maintenance status contain :<resource>_<action>' do
      before do
        Rack::TrafficSignal.setup do |config|
          config.maintenance_status_by do
            [:foo_bar]
          end
          config.maintenance_group = {
            foo: { bar: [ { methods: [:get], path: path } ] }
          }
        end
      end

      it 'should not return application response' do
        expect(subject.status).to eq(503)
      end
    end

    context 'when maintenance status contain :<resource>_all' do
      before do
        Rack::TrafficSignal.setup do |config|
          config.maintenance_status_by do
            [:foo_all]
          end
          config.maintenance_group = {
            foo: { bar: [ { methods: [:get], path: path } ] }
          }
        end
      end

      it 'should not return application response' do
        expect(subject.status).to eq(503)
      end
    end

    context 'when maintenance status contain :all' do
      before do
        Rack::TrafficSignal.setup do |config|
          config.maintenance_status_by do
            [:all]
          end
          config.maintenance_group = {
            foo: { bar: [ { methods: [:get], path: path } ] }
          }
        end
      end

      it 'should not return application response' do
        expect(subject.status).to eq(503)
      end
    end

    context 'when multiple config applied' do
      let(:path) { '/foo/bar' }
      before do
        Rack::TrafficSignal.setup do |config|
          config.maintenance_status_by do
            [:all]
          end
          config.maintenance_group = {
            more: { concrete: [ { methods: [:get], path: %r{\A/foo/bar}, status: 500 } ] },
            very: { abstract: [ { methods: [:get], path: %r{\A/}, status: 502 } ] },
            less: { concrete: [ { methods: [:get], path: %r{\A/foo}, status: 501 } ] },
          }
        end
      end
      it 'should apply more general config' do
        expect(subject.status).to eq(502)
      end
    end
  end
end