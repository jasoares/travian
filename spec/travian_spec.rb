require 'spec_helper'

module Travian
  describe '.MAIN_HUB' do
    subject { Travian::MAIN_HUB }

    it { should == 'http://www.travian.com/' }
  end

  describe '.hubs' do
    before(:all) { fake 'www.travian.com' }

    let(:hubs) { Travian.hubs }

    subject { hubs }

    it { should be_a HubsHash }

    it { should have_key :pt }

    its(:size) { should be 55 }

    it 'each value should be a Hub' do
      hubs.values.all? {|v| v.should be_a Hub }
    end

    context 'when no options are passed' do
      before(:each) do
        Travian.clear
      end

      it 'only fetches the hub list' do
        expect{ Travian.hubs }.not_to raise_exception
      end
    end

    context 'when passed :preload => :servers' do
      it 'fetches every hub servers list in advance' do
        Travian.hubs.each {|hub| hub.should_receive(:servers) }
        Travian.hubs(:preload => :servers)
      end
    end

    context 'when passed :preload => :all' do
      before(:each) do
        @server = double('Server', attributes: nil)
      end

      it 'fetches every hub location, servers and its attributes in advance' do
        Travian.hubs.each do |hub|
          hub.should_receive(:servers).twice.and_return([@server])
        end
        @server.should_receive(:attributes)
        Travian.hubs(:preload => :all)
      end
    end

    after(:all) { unfake }
  end

  describe '::LoginData' do
    let(:pt_data) { load_servers_login_data('www.travian.pt') }

    it 'returns a LoginData object loaded with the data passed as argument' do
      Travian::LoginData(pt_data[8]).should be_a LoginData
    end
  end

  describe '::ServerData' do
    let(:ptx_data) { load_server_data('tx3.travian.pt') }

    it 'returns a ServerData object loaded with the data passed as argument' do
      Travian::ServerData(ptx_data).should be_a ServerData
    end
  end

  describe '::Hub' do
    it 'returns a Travian::Hub object when passed a valid object' do
      hub = double('Hub', code: 'de', host: 'http://www.travian.de/')
      Travian::Hub(hub).should be_a Hub
    end

    it 'raises ArgumentError when passed an object that does not respond to :code' do
      hub = double('Hub', host: 'http://www.travian.de/')
      expect { Travian::Hub(hub) }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError when passed an object that does not respond to :host' do
      hub = double('Hub', code: 'de')
      expect { Travian::Hub(hub) }.to raise_error(ArgumentError)
    end
  end

  describe '::Server' do
    it 'returns a Travian::Server object when passed a valid object' do
      hub = double('Hub')
      server = double('Server', hub: hub, host: 'http://tx3.travian.de/')
      Travian::Server(server).should be_a Server
    end

    it 'raises ArgumentError when passed an object that does not respond to :hub' do
      server = double('Server', host: 'http://tx3.travian.de/')
      expect { Travian::Server(server) }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError when passed an object that does not respond to :host' do
      server = double('Server', hub: nil)
      expect { Travian::Server(server) }.to raise_error(ArgumentError)
    end
  end
end
