require 'spec_helper'

module Travian
  describe ServersHash do
    context 'given the ServersHash built from the portuguese hub' do
      before(:all) { fake 'www.travian.pt/serverLogin.php', :post }
      before(:each) do
        hub = double('Hub', :host => 'http://www.travian.pt/')
        @hash = ServersHash.build(hub)
      end

      subject  { @hash }

      it { should_not have_key :tc9 }

      it { should have(9).servers }

      it { should_not be_empty }

      its(:size) { should be 9 }

      its(:keys) { should === [:ts1, :ts10, :ts2, :ts3, :ts4, :ts5, :ts6, :ts7, :tx3] }

      after(:all) { unfake }
    end

    context 'given the ServersHash built from the german hub' do
      before(:all) { fake 'www.travian.de/serverLogin.php', :post }
      before(:each) do
        hub = double('Hub', :host => 'http://www.travian.de/')
        @hash = ServersHash.build(hub)
      end

      subject  { @hash }

      it { should_not have_key :tcx8 }

      it { should have(7).servers }

      it { should_not be_empty }

      its(:size) { should be 7 }

      its(:keys) { should == [:ts1, :ts2, :ts3, :ts5, :ts7, :ts8, :tx3] }

      after(:all) { unfake }
    end

    context 'given the ServersHash built from the new zealand hub' do
      before(:all) do
        fake_redirection({'www.travian.co.nz/serverLogin.php' => 'www.travian.com.au'}, :post)
        fake 'www.travian.com.au'
        hub = Hub.new(:nz, 'http://www.travian.co.nz/')
        @hash = ServersHash.build(hub)
      end

      subject { @hash }

      it { should have(0).servers }

      its(:size) { should be 0 }

      it { should be_empty }

      after(:all) { unfake }
    end

    describe '.new' do
      it 'raises ArgumentError when passed an argument that is not a Hash' do
        expect { ServersHash.new(123) }.to raise_error(ArgumentError)
      end
    end

    shared_context 'when passed servers_data' do
      before(:all) { fake 'www.travian.pt/serverLogin.php', :post }
      before(:each) do
        @hub = double('Hub', :host => 'http://www.travian.pt/')
        @servers_data = Nokogiri::HTML(ServersHash.fetch_servers(@hub.host))
        @server_data = ServersHash.send(:split_servers, @servers_data)[-2]
      end
      after(:all) { unfake }
    end

    describe '.build' do
      include_context 'when passed servers_data'

      it 'returns a Hash object' do
        ServersHash.build(@hub).should be_a ServersHash
      end

      it 'delegates the data splitting to ServersHash.select_servers' do
        ServersHash.should_receive(:split_servers).once.and_call_original
        ServersHash.build(@hub)
      end

      it 'delegates login data parsing to LoginData.parse' do
        LoginData.should_receive(:parse).exactly(10).times.and_call_original
        ServersHash.build(@hub)
      end

      it 'calls LoginData.new to create the object to return' do
        ServersHash.should_receive(:new).with(kind_of(Hash)).once
        ServersHash.build(@hub)
      end
    end

    describe '.fetch_servers' do
      before(:all) { fake 'www.travian.pt/serverLogin.php', :post }

      it 'returns the response body when passed a valid host' do
        ServersHash.fetch_servers('http://www.travian.pt/').should match /^<h1>Escolhe um servidor.<\/h1>/
      end

      after(:all) { unfake }
    end
  end
end
