#encoding: utf-8
require 'spec_helper'

module Travian
  describe RegisterData do
    let(:klass) { RegisterData }
    let(:pt_data) { load_register_data 'www.travian.pt' }
    let(:sa_data) { load_register_data 'www.travian.com.sa' }
    let(:restarting_server_data) { sa_data.css('div[class~="serverPreRegister"]') }
    let(:hub) { double('Hub', tld: 'com.sa', code: 'sa') }

    before(:all) { fake 'ts4.travian.com.sa' }

    describe '.parse' do
      it 'returns a hash of restarting servers with only the host' do
        klass.parse(sa_data, hub).should == { ts4: { host: "ts4.travian.com.sa" } }
      end

      it 'returns an empty hash when no restarting servers are found' do
        hub = double('Hub', :tld => 'pt', code: 'pt')
        klass.parse(pt_data, hub).should == {}
      end

      it 'supports the arabia edge case' do
        fake 'arabiats4.travian.com', :get, 'ts4.travian.com.sa'
        hub = double('Hub', :tld => 'com', code: 'arabia')
        klass.parse(sa_data, hub).should == { arabiats4: { host: "arabiats4.travian.com" } }
      end
    end

    describe '.parse_name' do
      it 'returns the number inside the div.name element' do
        klass.parse_name(restarting_server_data).should == "السيرفر 4"
      end
    end

    describe '.find_restarting_host' do
      it 'returns the restarting host for the given number and hub' do
        klass.find_restarting_host(restarting_server_data, hub).should == "ts4.travian.com.sa"
      end

      it 'returns nil if the restarting host is not found' do
        Server.stub_chain(:new, :restarting?).and_return(false)
        klass.find_restarting_host(restarting_server_data, hub).should == nil
      end
    end

    describe '.select_restarting_servers' do
      it 'returns 1 server when only one class has the value "serverPreRegister"' do
        klass.select_restarting_servers(sa_data).should have(1).server
      end
    end

    describe '.possible_codes' do
      it 'returns "ts1", "tc1" when passed "Server 1"' do
        klass.possible_codes("Server 1").should == ["ts1", "tc1"]
      end

      it 'returns "ts2", "tc2" when passed "Server 2"' do
        klass.possible_codes("Server 2").should == ["ts2", "tc2"]
      end

      it 'returns "ts4", "tc4" when passed "Server 4"' do
        klass.possible_codes("السيرفر 4").should == ["ts4", "tc4", "tx4", "tcx4"]
      end

      it 'returns "ts3", "tc3", "tx3" and "tcx3" when passed "Server 3"' do
        klass.possible_codes("สปีด 3x").should == ["tx3", "tcx3", "ts3", "tc3"]
      end

      it 'returns "tx3", "tcx3", "ts3", "tc3" when passed "السرعة 3x"' do
        klass.possible_codes("السرعة 3x").should == ["tx3", "tcx3", "ts3", "tc3"]
      end

      it 'returns "ts5", "tc5", "tx5" and "tcx5" when passed "Server 5"' do
        klass.possible_codes("Server 5").should == ["ts5", "tc5", "tx5", "tcx5"]
      end

      it 'returns "tx8", "tcx8", "ts8" and "tc8" when passed "Speed 8x"' do
        klass.possible_codes("Speed 8x").should == ["tx8", "tcx8", "ts8", "tc8"]
      end

      it 'returns "ts8", "tc8", "tx8" and "tcx8" when passed "Server 8"' do
        klass.possible_codes("Server 8").should == ["ts8", "tc8", "tx8", "tcx8"]
      end

      it 'returns "ts17", "tc17", "tx17" and "tcx17" when passed "Server 17."' do
        klass.possible_codes("Server 17.").should == ["ts17", "tc17"]
      end

      it 'returns "cumhuriyet" when passed "Cumhuriyet"' do
        klass.possible_codes("Cumhuriyet").should == ["cumhuriyet"]
      end
    end

    after(:all) { unfake }
  end
end
