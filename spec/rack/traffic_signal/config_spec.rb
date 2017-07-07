require 'spec_helper'

describe 'Rack::TrafficSignal::Config' do
  let(:config) { Rack::TrafficSignal::Config.new }

  describe '#maintenance_group' do
    let(:maintenance_group) { { } }

    subject { config.maintenance_group = maintenance_group }

    context 'when maintenance_group is invalid' do
      context 'not hash' do
        let(:maintenance_group) { :aaa }

        it { expect { subject }.to raise_error(Rack::TrafficSignal::Exceptions::InvalidMaintenanceGroup) }
      end

      context 'inavlid structure 1' do
        let(:maintenance_group) { { aaa: 1 } }

        it { expect { subject }.to raise_error(Rack::TrafficSignal::Exceptions::InvalidMaintenanceGroup) }
      end

      context 'invalid structure 2' do
        let(:maintenance_group) { { aaa: { bbb: :ccc } } }

        it { expect { subject }.to raise_error(Rack::TrafficSignal::Exceptions::InvalidMaintenanceGroup) }
      end

      context 'insufficient keys' do
        let(:maintenance_group) { { aaa: { bbb: [ { ddd: 1 } ] } } }

        it { expect { subject }.to raise_error(Rack::TrafficSignal::Exceptions::InvalidMaintenanceGroup) }
      end
    end
  end

  describe '#maintenance_status' do
    let(:status) { [] }

    before { config.maintenance_status_by { status } }

    subject { config.maintenance_status }

    context 'when maintenance_status returns invalid state' do
      context 'not array' do
        let(:status) { :aaa }
        it { expect { subject }.to raise_error(Rack::TrafficSignal::Exceptions::InvalidMaintenanceStatus) }
      end

      context 'contain invalid state 1' do
        let(:status) { [:aaa] }
        it { expect { subject }.to raise_error(Rack::TrafficSignal::Exceptions::InvalidMaintenanceStatus) }
      end

      context 'contain invalid state 2' do
        let(:status) { [:aaa_aaa_aaa] }
        it { expect { subject }.to raise_error(Rack::TrafficSignal::Exceptions::InvalidMaintenanceStatus) }
      end
    end

    context 'when maintenance_status returns valid state' do
      let(:status) { [:all, :aaa_bbb] }
      it { expect { subject }.not_to raise_error(Rack::TrafficSignal::Exceptions::InvalidMaintenanceStatus) }
    end
  end
end
