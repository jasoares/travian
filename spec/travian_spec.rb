require 'spec_helper'

module Travian
  describe '.MAIN_HUB' do
    subject { Travian::MAIN_HUB }

    it { should == 'www.travian.com' }
  end

  describe '.data' do
    before(:all) { fake 'www.travian.com' }

    let(:data) { Travian.data }

    subject { data }

    it { should be_a Hash }

    it { should have_key :pt }

    its(:size) { should be 56 }

    it 'each value should be a Hub' do
      data.values.all? {|v| v.should be_a Hub }
    end

    after(:all) { unfake }
  end

  describe '.hubs' do
    context 'when no options are passed' do
      it 'should not include mirrors' do
        Travian.stub(:data).and_return({ kr: double('Hub', mirror?: true), com: double('Hub', mirror?: false) })
        Travian.hubs.size.should be 1
      end
    end

    context 'when passed { mirrors: true }' do
      it 'should include mirrors' do
        Travian.stub(:data).and_return({ kr: double('Hub', mirror?: true), com: double('Hub', mirror?: false) })
        Travian.hubs(mirrors: true).size.should be 2
      end
    end
  end

  describe '.preregisterable_servers' do
    it 'returns a flat array with all the preregisterable servers from each hub' do
      server = double('Server')
      hubs = [double('Hub', mirror?: false), double('Hub', mirror?: false)].each do |hub|
        hub.should_receive(:preregisterable_servers).and_return([server, server])
      end
      Travian.stub(hubs: hubs)
      Travian.preregisterable_servers.should == [server] * 4
    end
  end

  describe '.restarting_servers' do
    let(:restarting1) { double('Server', running?: false, restarting?: true,  host: 'ts4.travian.ee')     }
    let(:restarting2) { double('Server', running?: false, restarting?: true,  host: 'ts3.travian.pl')     }
    let(:restarting3) { double('Server', running?: false, restarting?: true,  host: 'ts2.travian.ru')     }
    let(:running)     { double('Server', running?: true,  restarting?: false, host: 'tx3.travian.pt')     }
    let(:ended)       { double('Server', running?: false, restarting?: false, host: 'ts5.travian.com.sa') }

    it 'returns an array containing all the restarting servers' do
      Travian.stub(status_servers: [restarting1, restarting2, running, ended])
      Travian.stub(preregisterable_servers: [restarting2, restarting3])
      Travian.restarting_servers.should == [restarting2, restarting3, restarting1]
    end
  end

  describe '.servers' do
    it 'includes status, running and preregisterable servers' do
      Travian.should_receive(:status_servers).and_return([])
      Travian.should_receive(:running_servers).and_return([])
      Travian.should_receive(:preregisterable_servers).and_return([])
      Travian.servers
    end

    it 'should not return duplicate servers' do
      Travian.stub(status_servers: [Server.new('tx3.travian.pt')])
      Travian.stub(running_servers: [Server.new('tx3.travian.pt')])
      Travian.stub(preregisterable_servers: [])
      Travian.servers.should == Travian.servers.uniq {|s| s.host }
    end
  end

  describe '::Hub' do
    it 'gets the hub object from the data hash' do
      Travian.should_receive(:data).and_return({ com: double('Hub') })
      Travian::Hub('www.travian.com')
    end

    it 'returns a Travian::Hub object when passed a valid object' do
      hub = double('Hub', host: 'www.travian.de')
      Travian.stub(:data).and_return({ de: Hub.new(:de, 'www.travian.de') })
      Travian::Hub(hub).should be_a Hub
    end

    it 'returns a Travian::Hub object when passed a valid string host' do
      hub = 'www.travian.com'
      Travian.stub(:data).and_return({ com: Hub.new(:com, 'www.travian.com') })
      Travian::Hub(hub).should be_a Hub
    end

    it 'raises ArgumentError when passed an object that does not respond to :host and is not a string' do
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

    it 'calls Server.new with host when server was not loaded by Hub\'s login or register data' do
      server = Server.new('ts10.travian.de')
      Travian.stub(:data).and_return({ de: {} })
      Server.should_receive(:new).with('ts10.travian.de')
      Travian::Server('ts10.travian.de')
    end

    it 'returns the server when found in the hub\'s server list' do
      server = Server.new('ts4.travian.de')
      Travian.stub(:data).and_return({ de: { ts4: server} })
      Server.should_not_receive(:new).with('ts4.travian.de')
      Travian::Server('ts4.travian.de')
    end
  end
end
