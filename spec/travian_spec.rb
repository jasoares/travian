require 'spec_helper'

module Travian
  describe '.MAIN_HUB' do
    subject { Travian::MAIN_HUB }

    it { should == 'www.travian.com' }
  end

  describe '.hubs' do
    before(:all) { fake 'www.travian.com' }

    let(:hubs) { Travian.hubs }

    subject { hubs }

    it { should be_a HubsHash }

    it { should have_key :pt }

    its(:size) { should be 56 }

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

  describe '.servers' do
    it 'calls .hubs with { preload: :servers } as options' do
      Travian.should_receive(:hubs).with(preload: :servers).and_return([])
      Travian.servers
    end
  end

  describe '::Hub' do
    it 'returns a Travian::Hub object when passed a valid object' do
      hub = double('Hub', code: 'de', host: 'www.travian.de')
      Travian::Hub(hub).should be_a Hub
    end

    it 'raises ArgumentError when passed an object that does not respond to :code' do
      hub = double('Hub', host: 'www.travian.de')
      expect { Travian::Hub(hub) }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError when passed an object that does not respond to :host' do
      hub = double('Hub', code: 'de')
      expect { Travian::Hub(hub) }.to raise_error(ArgumentError)
    end
  end

  describe '::Server' do
    before(:all) do
      fake 'www.travian.com'
      fake 'www.travian.de/serverLogin.php', :post
      fake 'www.travian.de/register.php', :post
    end

    it 'returns a Travian::Server object when passed a valid string host' do
      Travian::Server('tx3.travian.de').should be_a Server
    end

    it 'returns a Travian::Server object when passed an object that respond to :host' do
      server = double('Server', host: 'tx3.travian.de')
      Travian::Server(server).should be_a Server
    end

    it 'raises ArgumentError when passed an object that does not respond to :host or is a valid string host' do
      expect { Travian::Server(:tx3) }.to raise_error(
        ArgumentError,
        /Object passed must be a string host/
      )
    end

    it 'raises ArgumentError when passed an object that does not respond to :host' do
      server = double('Server', hub: nil)
      expect { Travian::Server(server) }.to raise_error(
        ArgumentError,
        /Object passed must .+ respond to :host/
      )
    end

    it 'calls Server.new with host when server was not loaded from login data and loads it' do
      server = Server.new('ts10.travian.de')
      Travian.hubs[:de].servers.should_receive(:<<).with(server)
      Server.should_receive(:new).with('ts10.travian.de').and_return(server)
      Travian::Server('ts10.travian.de')
    end

    it 'returns the server when found in the hub\'s server list' do
      server = Server.new('ts4.travian.de')
      servers = { :ts4 => server }
      servers.should_not_receive(:<<)
      Travian.stub_chain(:hubs, :[], :servers).and_return(servers)
      Server.should_not_receive(:new).with('ts4.travian.de')
      Travian::Server('ts4.travian.de')
    end
  end
end
