require "spec_helper"

RSpec.describe Rack::TrafficSignal do
  describe '.setup' do
    it 'yield block' do
      expect(Rack::TrafficSignal.config).to receive(:foo).with(:bar)
      Rack::TrafficSignal.setup { |conf| conf.foo(:bar) }
    end
  end

  describe '.internal_access?' do
    let(:internal_ips) { [] }
    let(:remote_addr) { '' }
    let(:env) { { 'REMOTE_ADDR' => remote_addr } }

    before do
      Rack::TrafficSignal.setup do |config|
        config.internal_ips = internal_ips
      end
    end

    subject { Rack::TrafficSignal.internal_access?(env) }

    context 'when ip' do
      let(:internal_ips) { ['192.168.0.1'] }

      context 'when address matched' do
        let(:remote_addr) { '192.168.0.1' }

        it 'should return true' do
          expect(subject).to be_truthy
        end
      end

      context 'when address did not match' do
        let(:remote_addr) { '192.168.0.12' }

        it 'should return false' do
          expect(subject).to be_falsey
        end
      end
    end

    context 'when ip with mask' do
      let(:internal_ips) { ['192.168.0.64/25'] }

      (0..127).each do |num|
        context 'when address matched' do
          let(:remote_addr) { "192.168.0.#{num}" }

          it 'should return true' do
            expect(subject).to be_truthy
          end
        end
      end

      (128..255).each do |num|
        context 'when address matched' do
          let(:remote_addr) { "192.168.0.#{num}" }

          it 'should return false' do
            expect(subject).to be_falsey
          end
        end
      end
    end
  end

  describe '.skip_path?' do
    let(:skip_paths) { [] }
    let(:path_info) { '' }
    let(:env) { { 'PATH_INFO' => path_info } }

    before do
      Rack::TrafficSignal.setup do |config|
        config.skip_paths = skip_paths
      end
    end

    subject { Rack::TrafficSignal.skip_path?(env) }

    context 'when skip path is String' do
      let(:skip_paths) { ['/users/12345'] }

      context 'when path_info does not match' do
        let(:path_info) { '/foo/bar' }
        it { expect(subject).to be_falsey }
      end

      context 'when path_info matches' do
        let(:path_info) { '/users/12345' }
        it { expect(subject).to be_truthy }
      end

      context 'when path_info matches' do
        let(:path_info) { '/users/12345/update' }
        it { expect(subject).to be_falsey }
      end
    end

    context 'when skip path is Regexp' do
      let(:skip_paths) { [%r{/users/12345}] }

      context 'when path_info does not match' do
        let(:path_info) { '/foo/bar' }
        it { expect(subject).to be_falsey }
      end

      context 'when path_info matches' do
        let(:path_info) { '/users/12345' }
        it { expect(subject).to be_truthy }
      end

      context 'when path_info matches' do
        let(:path_info) { '/users/12345/update' }
        it { expect(subject).to be_truthy }
      end
    end
  end
end
